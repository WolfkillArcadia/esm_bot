# frozen_string_literal: true

module ESM
  module Command
    module Server
      class ServerTerritories < ESM::Command::Base
        type :admin
        aliases :serverterritories, :allterritories, :all_territories
        limit_to :text
        requires :registration

        define :enabled, modifiable: true, default: true
        define :whitelist_enabled, modifiable: true, default: true
        define :whitelisted_role_ids, modifiable: true, default: []
        define :allowed_in_text_channels, modifiable: true, default: true
        define :cooldown_time, modifiable: true, default: 2.seconds

        argument :server_id
        argument :order_by, regex: /id|territory_name|owner_uid/, description: "commands.server_territories.arguments.order_by", default: :territory_name, type: :symbol

        def discord
          @checks.owned_server!
          deliver!(command_name: "allterritories", query: "list_territories_all")
        end

        def server
          # The data must an array if its not already.
          @response = [@response] if !@response.is_a?(Array)

          check_for_no_territories!

          tables = build_territory_tables
          tables.each { |table| reply("```\n#{table}\n```") }
        end

        def build_territory_tables
          tables = []
          rows = []
          territory_size = @response.size
          table = Terminal::Table.new(headings: ["ID", "Name", "Owner UID"], style: { width: 67 })

          # Sorted here on purpose. Makes it so I can test this functionality
          @response.sort_by!(&@arguments.order_by)

          # Two challenges for this code.
          # 1: The width of each row had to be less than 67 (10 characters per line reserved for spacing/separating)
          # 2: The overall size of the table (including spaces and separators) HAS to be under 1992 characters due to Discord's message limit
          @response.each_with_index do |territory, index|
            # Build the row we are currently on
            row = [
              territory.id.truncate(20),
              territory.territory_name.truncate(20),
              territory.owner_uid
            ]

            # Tell the table about the old rows plus a new row
            table.rows = rows + [row]

            # We've loaded all the territory, print out the table
            # This is needed for when there is only one territory
            break tables << table.to_s if territory_size == (index + 1)

            # If the table's size (including the new row) is less than 2000 - 8 (for the styling), store that row and go to the next one
            next rows << row if table.to_s.size < 1992

            # We've hit the max we can go with this table
            # Reset the rows (to not include the current row)
            table.rows = rows

            # Print the table to the array and reset the rows
            tables << table.to_s
            rows = [row]
          end

          # Return the tables
          tables
        end

        def check_for_no_territories!
          check_failed!(:no_server_territories, user: current_user.mention) if @response.blank?
        end
      end
    end
  end
end
