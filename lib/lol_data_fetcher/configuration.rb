# frozen_string_literal: true

module LolDataFetcher
  # Configuration class for global settings
  class Configuration
    attr_accessor :default_version, :default_language, :cache_enabled, :cache_ttl, :timeout

    def initialize
      @default_version = nil # nil = fetch latest
      @default_language = "en_US"
      @cache_enabled = false
      @cache_ttl = 3600 # 1 hour in seconds
      @timeout = 10 # seconds
    end
  end
end
