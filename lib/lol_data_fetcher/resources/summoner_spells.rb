# frozen_string_literal: true

module LolDataFetcher
  module Resources
    # Resource for fetching summoner spell data
    class SummonerSpells < Base
      # Fetch all summoner spells
      # @return [Hash] Hash containing all summoner spells data
      def all
        get(cdn_path("summoner"))
      end

      # Find a specific summoner spell by ID
      # @param id [String, Integer] Summoner spell ID
      # @return [Hash, nil] Summoner spell data or nil if not found
      def find(id)
        all.dig("data", id.to_s)
      end

      # List all summoner spell IDs
      # @return [Array<String>] Array of summoner spell IDs
      def list_ids
        all.dig("data")&.keys || []
      end

      # Search summoner spells by name (case-insensitive)
      # @param query [String] Search query (case-insensitive)
      # @return [Array<Hash>] Array of matching summoner spells
      def search(query)
        spells = all.dig("data") || {}
        spells.select { |_id, spell| spell["name"]&.downcase&.include?(query.downcase) }.values
      end

      # Find summoner spell by exact name match (case-insensitive)
      # @param name [String] Summoner spell name (case-insensitive)
      # @return [Hash, nil] Summoner spell data or nil if not found
      def find_by_name(name)
        spells = all.dig("data") || {}
        spells.find { |_id, spell| spell["name"]&.downcase == name.downcase }&.last
      end
    end
  end
end
