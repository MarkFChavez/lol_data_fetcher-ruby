# frozen_string_literal: true

module LolDataFetcher
  module Resources
    # Resource for fetching item data
    class Items < Base
      # Fetch all items
      # @return [Hash] Hash containing all items data
      def all
        get(cdn_path("item"))
      end

      # Find a specific item by ID
      # @param id [String, Integer] Item ID
      # @return [Hash, nil] Item data or nil if not found
      def find(id)
        all.dig("data", id.to_s)
      end

      # List all item IDs
      # @return [Array<String>] Array of item IDs
      def list_ids
        all.dig("data")&.keys || []
      end

      # Search items by name (case-insensitive)
      # @param query [String] Search query (case-insensitive)
      # @return [Array<Hash>] Array of matching items
      def search(query)
        items = all.dig("data") || {}
        items.select { |_id, item| item["name"]&.downcase&.include?(query.downcase) }.values
      end

      # Find item by exact name match (case-insensitive)
      # @param name [String] Item name (case-insensitive)
      # @return [Hash, nil] Item data or nil if not found
      def find_by_name(name)
        items = all.dig("data") || {}
        items.find { |_id, item| item["name"]&.downcase == name.downcase }&.last
      end
    end
  end
end
