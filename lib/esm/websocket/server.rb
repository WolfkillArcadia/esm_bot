# frozen_string_literal: true

module ESM
  class Websocket
    class Server
      def initialize
        Faye::WebSocket.load_adapter("puma")
        events = Puma::Events.new($stdout, $stderr)
        binder = Puma::Binder.new(events)
        binder.parse(["tcp://localhost:#{ENV["WEBSOCKET_PORT"]}"], self)
        @server = Puma::Server.new(self, events)
        @server.binder = binder
        @server.run
      end

      def call(env)
        return if !Faye::WebSocket.websocket?(env)

        # Create a new websocket client
        ws = Faye::WebSocket.new(env)

        # Bind it with ESM
        ESM::Websocket.new(ws)

        # Return async Rack response
        ws.rack_response
      end

      def log(*args)
        ESM.logger.info("#{self.class}##{__method__}") { "Websocket server is running on #{args.first}" }
      end

      def stop
        ESM::Websocket::RequestWatcher.stop!
        ESM::Websocket::ConnectionWatcher.stop!
        @server.stop(true)
      end
    end
  end
end
