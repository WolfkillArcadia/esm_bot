# frozen_string_literal: true

module ESM
  module Command
    module Test
      class ServerSuccessCommand < ESM::Command::Base
        type :player
        requires :registration

        define :enabled, modifiable: true, default: true
        define :whitelist_enabled, modifiable: true, default: false
        define :whitelisted_role_ids, modifiable: true, default: []
        define :allowed_in_text_channels, modifiable: true, default: true
        define :cooldown_time, modifiable: true, default: 2.seconds

        argument :server_id

        def discord
          deliver!
        end

        def server
          reply("Yaay")
        end
      end
    end
  end
end
