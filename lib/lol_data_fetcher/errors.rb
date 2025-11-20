# frozen_string_literal: true

module LolDataFetcher
  # Base error class for all LolDataFetcher errors
  class Error < StandardError; end

  # Raised when an API request fails
  class ApiError < Error; end

  # Raised when a requested resource is not found
  class NotFoundError < ApiError; end

  # Raised when rate limit is exceeded
  class RateLimitError < ApiError; end

  # Raised when there's a configuration issue
  class ConfigurationError < Error; end
end
