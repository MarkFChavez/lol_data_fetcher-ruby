# frozen_string_literal: true

module LolDataFetcher
  module Resources
    # Resource for fetching game version information
    class Versions < Base
      # Fetch all available versions
      # @return [Array<String>] List of version strings
      def all
        get("/api/versions.json")
      end

      # Fetch the latest version
      # @return [String] Latest version string
      def latest
        all.first
      end

      # Check if a version exists
      # @param version [String] Version to check
      # @return [Boolean] True if version exists
      def exists?(version)
        all.include?(version)
      end
    end
  end
end
