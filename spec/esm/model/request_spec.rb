# frozen_string_literal: true

describe ESM::Request do
  let!(:user_1) { ESM::Test.user }
  let!(:user_2) { ESM::Test.second_user }
  let(:request) do
    channel_id = [ESM::Community::ESM::SPAM_CHANNEL, ESM::Community::Secondary::SPAM_CHANNEL].sample

    create(
      :request,
      requestor_user_id: user_1.id,
      requestee_user_id: user_2.id,
      requested_from_channel_id: channel_id,
      command_name: "id"
    )
  end

  describe "scope#expired" do
    it "should return expired requests" do
      request.update(expires_at: Time.current - 1.days)
      expect(ESM::Request.expired.size).to eql(1)
    end
  end

  describe "#respond" do
    it "should be accepted" do
      expect { request.respond(true) }.not_to raise_error
      expect(request.accepted).to be(true)
    end

    it "should be denied" do
      expect { request.respond(false) }.not_to raise_error
      expect(request.accepted).to be(false)
    end

    it "should respond" do
      expect { request.respond(true) }.not_to raise_error
      expect(ESM::Request.all.size).to eql(0)
    end
  end
end
