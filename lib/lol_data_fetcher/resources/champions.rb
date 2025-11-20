# frozen_string_literal: true

module LolDataFetcher
  module Resources
    # Resource for fetching champion data
    class Champions < Base
      # Fetch all champions (overview data)
      # @return [Hash] Hash containing all champions data
      def all
        get(cdn_path("champion"))
      end

      # Fetch detailed data for a specific champion including skills
      # @param name [String] Champion name (e.g., "Ahri", "MasterYi")
      # @return [Hash] Detailed champion data including spells/skills
      def find(name)
        get(cdn_path("champion/#{name}"))
      end

      # Get passive ability for a specific champion
      # @param name [String] Champion name (e.g., "Ahri", "MasterYi")
      # @return [Hash, nil] Passive ability data or nil if not found
      def passive(name)
        find(name).dig("data", name, "passive")
      end

      # List all champion names
      # @return [Array<String>] Array of champion names
      def list_names
        all.dig("data")&.keys || []
      end

      # Get champion by ID
      # @param id [String, Integer] Champion ID
      # @return [Hash, nil] Champion data or nil if not found
      def find_by_id(id)
        all.dig("data")&.find { |_key, champ| champ["key"] == id.to_s }&.last
      end
    end
  end
end
