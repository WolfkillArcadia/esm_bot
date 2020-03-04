# frozen_string_literal: true

require "esm/websocket/connection_watcher"
require "esm/websocket/request"
require "esm/websocket/request_watcher"
require "esm/websocket/queue"
require "esm/websocket/server"
require "esm/websocket/server_request"

module ESM
  class Websocket
    class << self
      attr_reader :connections, :server_ids
    end

    ###########################
    # Public Class Methods
    ###########################

    # Starts the websocket server and the request watcher thread
    def self.start!
      @connections = {}
      @server_ids = ESM::Server.all.pluck(:server_id)

      # Start the websocket server
      # @note If the event machine is not running, the WS server will "delay" sending messages, if at all.
      EventMachine.run_block do
        ESM::Websocket::Server.new
      end

      # Watches over requests and removes them if the server is taking too long to respond
      ESM::Websocket::RequestWatcher.start!

      # Pings the clients every so often to keep the connection alive
      ESM::Websocket::ConnectionWatcher.start!
    end

    # Delivers the message to the requested server_id
    def self.deliver!(server_id, command: nil, user: nil, channel: nil, parameters: [], timeout: 30)
      connection = @connections[server_id]
      connection.deliver!(command: command, user: user, channel: channel, parameters: parameters, timeout: timeout)
    rescue StandardError => e
      ESM.logger.fatal("#{self.class}##{__method__}") { "Message:\n#{e.message}\n\nBacktrace:\n#{e.backtrace}" }
      nil
    end

    # Adds a new connection to the connections
    def self.add_connection(connection)
      # Uniquely append to the server IDs array
      @server_ids |= [connection.server.server_id]
      @connections[connection.server.server_id] = connection
    end

    # Removes a connection from the connections
    def self.remove_connection(connection)
      connection.server.update(disconnected_at: ::Time.now) if !ESM.env.test?
      @server_ids.delete(connection.server.server_id)
      @connections.delete(connection.server.server_id)
    end

    # Removes all connections
    def self.remove_all_connections!
      @connections.each { |server_id, connection| self.remove_connection(connection) }
    end

    # Checks to see if there are any corrections and provides them for the server id
    def self.correct(server_id)
      checker = DidYouMean::SpellChecker.new(dictionary: @server_ids)
      checker.correct(server_id)
    end

    def self.connected?(server_id)
      !@connections[server_id].nil?
    end

    ###########################
    # Public Instance Methods
    ###########################
    attr_reader :server, :connection, :requests
    attr_writer :requests if ESM.env.test?

    def initialize(connection)
      @connection = connection
      @requests = ESM::Websocket::Queue.new
      bind_events

      on_open
    end

    def deliver!(command:, user:, channel:, parameters:, timeout:)
      request = add_request(command: command, user: user, channel: channel, parameters: parameters, timeout: timeout)
      @connection.send(request.to_s)
      request
    end

    # Removes a request via its commandID
    # @returns [ESM::Websocket::Request, nil]
    def remove_request(command_id)
      @requests.remove(command_id)
    end

    ###########################
    # Private Instance Methods
    ###########################
    private

    # @private
    # Authorizes the request from the DLL based on its server key
    def authorize!
      # authorization header is "basic BASE_64_STRING"
      authorization = @connection.env["HTTP_AUTHORIZATION"][6..-1]

      raise ESM::Exception::FailedAuthentication, "Missing authorization key" if authorization.blank?

      # Once decoded, it becomes "arma_server:esm_key"
      key = Base64.strict_decode64(authorization)[12..-1]

      @server = ESM::Server.where(server_key: key).first
      raise ESM::Exception::FailedAuthentication, "Invalid Key" if @server.nil?
    end

    # @private
    def bind_events
      @connection.on(:close, &method(:on_close))
      @connection.on(:message, &method(:on_message))
      @connection.on(:pong, &method(:on_pong))
    end

    # @private
    # Adds a request to the servers requests and returns it
    # @return [ESM::Websocket::Request]
    def add_request(command:, user:, channel:, parameters:, timeout:)
      request = ESM::Websocket::Request.new(command: command, user: user, channel: channel, parameters: parameters, timeout: timeout)

      # If the user is nil, there is no point in tracking the request
      @requests << request if !user.nil?
      request
    end

    # @private
    # Websocket event, executes when a A3 server connects
    def on_open
      # Authorize the request and extract the server key
      authorize!

      # Tell the server to store the connection for access later
      ESM::Websocket.add_connection(self)

      ESM.logger.info("#{self.class}##{__method__}") { "#{@server.server_id} has connected" }
    rescue ESM::Exception::FailedAuthentication => e
      # Application code may only use codes from 1000, 3000-4999
      @connection.close(1000, e.message)
    rescue StandardError => e
      ESM.logger.fatal("#{self.class}##{__method__}") { "Message:\n#{e.message}\n\nBacktrace:\n#{e.backtrace}" }
    end

    # @private
    # Websocket event, executes when a A3 server sends a message
    def on_message(event)
      # Messages with commandID are requests from the Bot
      # Messages without are DLL generated requests
      message = event.data.to_ostruct

      # These are normally empty responses
      # message.returned is legacy
      return if message.ignore || message.returned

      # Process the request
      ESM::Websocket::ServerRequest.new(connection: self, message: message).process
    rescue ESM::Exception::CheckFailure
      # Exception supressed because #check_for_command_error! can respond via the request
      nil
    end

    # @private
    # Websocket event, executes when a A3 server or the WebServer disconnects the connection
    def on_close(_code)
      return if @server.nil?

      ESM::Websocket.remove_connection(self)
    end

    # @private
    # Websocket event, executes when the A3 server replies to a pong? IDK yet, untested.
    def on_pong(message)
      puts "[WS on_pong] #{message}"
    end
  end
end
