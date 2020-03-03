# frozen_string_literal: true

describe ESM::Command::General::Whois, category: "command" do
  let!(:command) { ESM::Command::General::Whois.new }

  before :example do
    ESM::Test.skip_cooldown = true
  end

  it "should be valid" do
    expect(command).not_to be_nil
  end

  it "should have 1 argument" do
    expect(command.arguments.size).to eql(1)
  end

  it "should have a description" do
    expect(command.description).not_to be_blank
  end

  it "should have examples" do
    expect(command.example).not_to be_blank
  end

  describe "#execute" do
    let!(:community) { ESM::Test.community }
    let!(:user) { ESM::Test.user }

    it "should run (mention)" do
      response = nil

      event = CommandEvent.create("!whois #{user.mention}", user: user, channel_type: :text)
      expect { response = command.execute(event) }.not_to raise_error
      expect(response).not_to be_nil
      expect(response.fields).not_to be_empty
    end

    it "should run (steam_uid)" do
      response = nil

      event = CommandEvent.create("!whois #{user.steam_uid}", user: user, channel_type: :text)
      expect { response = command.execute(event) }.not_to raise_error
      expect(response).not_to be_nil
      expect(response.fields).not_to be_empty
    end

    it "should run (discord id)" do
      response = nil

      event = CommandEvent.create("!whois #{user.discord_id}", user: user, channel_type: :text)
      expect { response = command.execute(event) }.not_to raise_error
      expect(response).not_to be_nil
      expect(response.fields).not_to be_empty
    end

    it "should run (not registered)" do
      response = nil

      user.update(steam_uid: "")
      event = CommandEvent.create("!whois #{user.mention}", user: user, channel_type: :text)
      expect { response = command.execute(event) }.not_to raise_error
      expect(response).not_to be_nil
      expect(response.fields).not_to be_empty
    end
  end
end
