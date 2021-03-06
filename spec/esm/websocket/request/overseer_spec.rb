# frozen_string_literal: true

describe ESM::Websocket::Request::Overseer do
  let!(:community) { ESM::Test.community }
  let!(:server) { ESM::Test.server }
  let!(:user) { ESM::Test.user }
  let!(:connection) { WebsocketClient.new(server) }

  before :each do
    wait_for { connection.connected? }.to be(true)
  end

  after :each do
    connection.disconnect!
  end

  describe "Timeout Thread" do
    let!(:server_connection) { ESM::Websocket.connections[server.server_id] }
    let!(:iterations) { Faker::Number.between(from: 1, to: 10) }

    before :each do
      iterations.times do
        server_connection.requests << ESM::Websocket::Request.new(user: nil, channel: nil, command_name: "testing", parameters: nil)
      end
    end

    it "should not time out" do
      expect(server_connection.requests.size).to eql(iterations)
      sleep(1)
      expect(server_connection.requests.size).to eql(iterations)
    end

    it "should remove the timed out request" do
      command = ESM::Command::Test::PlayerCommand.new
      event = CommandEvent.create(command.statement, user: user)
      command.event = event

      server_connection.requests << ESM::Websocket::Request.new(user: user.discord_user, command: command, channel: nil, parameters: nil, timeout: 0)

      expect(server_connection.requests.size).to eql(iterations + 1)
      sleep(1)
      expect(server_connection.requests.size).to eql(iterations)
      expect(ESM::Test.messages.size).to eql(1)
      expect(ESM::Test.messages.first[1].description).to match(/never replied to your command/i)
    end
  end
end
