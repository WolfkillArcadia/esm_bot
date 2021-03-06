# frozen_string_literal: true

class CommandEvent
  def self.channel_id(user, channel_type)
    return user.GUILD_TYPE == :primary ? ESM::Community::ESM::SPAM_CHANNEL : ESM::Community::Secondary::SPAM_CHANNEL if channel_type == :text

    user.discord_user.pm.id
  end

  def self.guild_id(user)
    user.GUILD_TYPE == :primary ? ESM::Community::ESM::ID : ESM::Community::Secondary::ID
  end

  # Can't use initializer because I want to return a different object. This is essentially a wrapper
  def self.create(content, user:, channel_type: :text)
    # This command is expensive in the terms of requests to Discord.
    # Forces tests to run a little bit slower so Discord doesn't ratelimit me
    sleep(rand + 0.5)

    data = {
      "id" => nil,
      "content" => content,
      "channel_id" => channel_id(user, channel_type),
      "guild_id" => guild_id(user),
      "pinned" => false,
      "author" => {
        "id" => user.discord_id,
        "discriminator" => user.discord_discriminator,
        "username" => user.discord_username
      }
    }

    message = Discordrb::Message.new(data, ESM.bot)
    Discordrb::Commands::CommandEvent.new(message, ESM.bot)
  end
end
