# frozen_string_literal: true

module ESM
  module Command
    module Test
      class SkipCooldownCommand < ESM::Command::Base
        define :enabled, modifiable: true, default: true
        define :whitelist_enabled, modifiable: true, default: false
        define :whitelisted_role_ids, modifiable: true, default: []
        define :allowed_in_text_channels, modifiable: true, default: true
        define :cooldown_time, modifiable: true, default: 2.seconds

        def discord
          skip(:cooldown)
        end

        def server; end
      end
    end
  end
end