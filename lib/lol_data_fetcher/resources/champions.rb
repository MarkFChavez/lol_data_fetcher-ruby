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
      # Supports case-insensitive search (e.g., "ahri", "AHRI", "Ahri")
      # @param name [String] Champion name (case-insensitive)
      # @return [Hash] Detailed champion data including spells/skills
      def find(name)
        normalized_name = normalize_name(name)
        data = get(cdn_path("champion/#{normalized_name}"))
        # Return data with the normalized name key
        data
      end

      # Get passive ability for a specific champion
      # Supports case-insensitive search
      # @param name [String] Champion name (case-insensitive)
      # @return [Hash, nil] Passive ability data or nil if not found
      def passive(name)
        normalized_name = normalize_name(name)
        find(normalized_name).dig("data", normalized_name, "passive")
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

      private

      # Normalize champion name to match Data Dragon API casing
      # Performs case-insensitive lookup to find the correct champion name
      # @param name [String] Champion name in any casing
      # @return [String] Properly-cased champion name for API
      # @raise [NotFoundError] If champion is not found
      def normalize_name(name)
        return name if name.nil? || name.empty?

        # Get all champion names from the API
        champions_data = all.dig("data")
        return name unless champions_data

        # Find the champion with case-insensitive matching
        normalized = champions_data.keys.find do |champion_name|
          champion_name.downcase == name.downcase
        end

        # If not found, raise an error
        unless normalized
          raise NotFoundError, "Champion '#{name}' not found. Check spelling and try again."
        end

        normalized
      end
    end
  end
end
