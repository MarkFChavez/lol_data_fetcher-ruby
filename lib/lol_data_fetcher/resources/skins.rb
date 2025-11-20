# frozen_string_literal: true

module LolDataFetcher
  module Resources
    # Resource for fetching champion skin data
    class Skins < Base
      # Fetch skins for a specific champion
      # Supports case-insensitive search (e.g., "ahri", "AHRI", "Ahri")
      # @param champion_name [String] Champion name (case-insensitive)
      # @return [Array<Hash>] Array of skin data with image URLs
      def for_champion(champion_name)
        # Use the champions resource to get the data with normalized name
        champion_data = client.champions.find(champion_name)

        # The find method returns data with the normalized name as key
        # We need to extract that key from the data
        normalized_name = champion_data.dig("data")&.keys&.first
        return [] unless normalized_name

        skins = champion_data.dig("data", normalized_name, "skins") || []

        skins.map do |skin|
          {
            "id" => skin["id"],
            "num" => skin["num"],
            "name" => skin["name"],
            "splash_url" => splash_url(normalized_name, skin["num"]),
            "loading_url" => loading_url(normalized_name, skin["num"]),
            "chromas" => skin["chromas"] || false
          }
        end
      end

      # Get all skins across all champions
      # @return [Hash] Hash of champion names to their skins
      def all
        champions_data = client.champions.all
        skins = {}

        champions_data.dig("data")&.each do |name, _champion|
          skins[name] = for_champion(name)
        rescue NotFoundError
          # Skip champions without detailed data
          next
        end

        skins
      end

      private

      # Build splash art URL for a skin
      # @param champion_name [String] Champion name
      # @param skin_num [Integer] Skin number
      # @return [String] Full URL to splash art
      def splash_url(champion_name, skin_num)
        "#{Client::BASE_URL}#{cdn_image_path('champion/splash', "#{champion_name}_#{skin_num}.jpg")}"
      end

      # Build loading screen URL for a skin
      # @param champion_name [String] Champion name
      # @param skin_num [Integer] Skin number
      # @return [String] Full URL to loading screen
      def loading_url(champion_name, skin_num)
        "#{Client::BASE_URL}#{cdn_image_path('champion/loading', "#{champion_name}_#{skin_num}.jpg")}"
      end
    end
  end
end
