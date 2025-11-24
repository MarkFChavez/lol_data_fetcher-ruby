# frozen_string_literal: true

require "faraday"
require "faraday/retry"

module LolDataFetcher
  # Main client class for interacting with the Data Dragon API
  class Client
    BASE_URL = "https://ddragon.leagueoflegends.com"

    attr_reader :version, :language

    # Initialize a new client
    # @param version [String, nil] Game version to use (nil = fetch latest)
    # @param language [String] Language code (default: "en_US")
    def initialize(version: nil, language: nil)
      @language = language || LolDataFetcher.configuration.default_language
      @version = version || LolDataFetcher.configuration.default_version || fetch_latest_version
    end

    # Access the champions resource
    # @return [LolDataFetcher::Resources::Champions]
    def champions
      @champions ||= Resources::Champions.new(self)
    end

    # Access the items resource
    # @return [LolDataFetcher::Resources::Items]
    def items
      @items ||= Resources::Items.new(self)
    end

    # Access the skins resource
    # @return [LolDataFetcher::Resources::Skins]
    def skins
      @skins ||= Resources::Skins.new(self)
    end

    # Access the summoner_spells resource
    # @return [LolDataFetcher::Resources::SummonerSpells]
    def summoner_spells
      @summoner_spells ||= Resources::SummonerSpells.new(self)
    end

    # Access the versions resource
    # @return [LolDataFetcher::Resources::Versions]
    def versions
      @versions ||= Resources::Versions.new(self)
    end

    # Returns the Faraday connection object
    # @return [Faraday::Connection]
    def connection
      @connection ||= Faraday.new(url: BASE_URL) do |faraday|
        faraday.request :retry, max: 3, interval: 0.5, backoff_factor: 2
        faraday.response :json, content_type: /\bjson$/
        faraday.response :raise_error
        faraday.options.timeout = LolDataFetcher.configuration.timeout
        faraday.adapter Faraday.default_adapter
      end
    end

    private

    def fetch_latest_version
      versions.latest
    rescue StandardError => e
      raise ConfigurationError, "Failed to fetch latest version: #{e.message}"
    end
  end
end

# Require resources after client is defined
require_relative "resources/base"
require_relative "resources/versions"
require_relative "resources/champions"
require_relative "resources/items"
require_relative "resources/skins"
require_relative "resources/summoner_spells"
