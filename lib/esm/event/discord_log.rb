# frozen_string_literal: true

module ESM
  module Event
    class DiscordLog
      def initialize(server, params)
        @server = server
        @community = server.community
        @params = params.log_info
      end

      # params
      #   template [embed, message]
      #   message -> if template == "message"
      #   embed [title, description, fields: [name, value, inline]] -> if template == "embed"
      #   type [success, warn, error]
      def run!
        message =
          case @params.template
          when "message"
            @params.message
          when "embed"
            build_embed
          end

        @community.log_event(:discord_log, message)
      end

      private

      def build_embed
        # Unpack the array
        title, description, fields = JSON.parse(@params.embed)

        # Build an embed from the values
        ESM::Embed.build do |e|
          e.title = title.to_s
          e.description = description.to_s

          fields.each do |field|
            e.add_field(name: field.first.to_s, value: field.second.to_s, inline: field.third || false)
          end

          e.color =
            case @params.type
            when "success"
              :green
            when "warn"
              :yellow
            when "error"
              :red
            when "info"
              :blue
            else
              ESM::Color.random
            end
        end
      rescue StandardError
        I18n.t("exceptions.invalid_discord_log", server: @server.server_id, message: @params.embed)
      end
    end
  end
end
