# frozen_string_literal: true

require_relative "lol_data_fetcher/version"
require_relative "lol_data_fetcher/errors"
require_relative "lol_data_fetcher/configuration"

module LolDataFetcher
  class << self
    attr_writer :configuration

    # Returns the global configuration object
    # @return [LolDataFetcher::Configuration]
    def configuration
      @configuration ||= Configuration.new
    end

    # Yields the configuration object for setup
    # @yield [LolDataFetcher::Configuration]
    def configure
      yield(configuration)
    end

    # Returns a new client instance
    # @return [LolDataFetcher::Client]
    def client
      @client ||= Client.new
    end

    # Resets the configuration and client to defaults
    def reset!
      @configuration = Configuration.new
      @client = nil
    end
  end
end

# Require client and resources after module is defined
require_relative "lol_data_fetcher/client"
