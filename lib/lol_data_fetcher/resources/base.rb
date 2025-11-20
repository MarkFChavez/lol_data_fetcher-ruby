# frozen_string_literal: true

module LolDataFetcher
  module Resources
    # Base class for all resource classes
    class Base
      attr_reader :client

      # Initialize a new resource
      # @param client [LolDataFetcher::Client] The client instance
      def initialize(client)
        @client = client
      end

      private

      # Make a GET request to the API
      # @param path [String] The API path
      # @param params [Hash] Query parameters
      # @return [Hash] Parsed JSON response
      # @raise [LolDataFetcher::ApiError] If the request fails
      def get(path, params = {})
        response = client.connection.get(path, params)
        response.body
      rescue Faraday::ResourceNotFound => e
        raise NotFoundError, "Resource not found: #{path}"
      rescue Faraday::Error => e
        raise ApiError, "API request failed: #{e.message}"
      end

      # Build a CDN path for data resources
      # @param resource [String] The resource name (e.g., "champion", "item")
      # @return [String] The full CDN path
      def cdn_path(resource)
        "/cdn/#{client.version}/data/#{client.language}/#{resource}.json"
      end

      # Build a CDN path for image resources
      # @param type [String] Image type (e.g., "champion/splash")
      # @param filename [String] The image filename
      # @return [String] The full CDN image path
      def cdn_image_path(type, filename)
        "/cdn/img/#{type}/#{filename}"
      end
    end
  end
end
