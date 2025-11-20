# frozen_string_literal: true

RSpec.describe LolDataFetcher do
  it "has a version number" do
    expect(LolDataFetcher::VERSION).not_to be nil
  end

  describe ".configuration" do
    it "returns a Configuration instance" do
      expect(LolDataFetcher.configuration).to be_a(LolDataFetcher::Configuration)
    end
  end

  describe ".configure" do
    it "yields the configuration" do
      expect { |b| LolDataFetcher.configure(&b) }.to yield_with_args(LolDataFetcher::Configuration)
    end

    it "allows setting configuration options" do
      LolDataFetcher.configure do |config|
        config.default_language = "fr_FR"
      end

      expect(LolDataFetcher.configuration.default_language).to eq("fr_FR")
    end
  end

  describe ".client", :vcr do
    it "returns a Client instance" do
      expect(LolDataFetcher.client).to be_a(LolDataFetcher::Client)
    end

    it "memoizes the client" do
      expect(LolDataFetcher.client.object_id).to eq(LolDataFetcher.client.object_id)
    end
  end

  describe ".reset!" do
    it "resets configuration to defaults", :vcr do
      LolDataFetcher.configure do |config|
        config.default_language = "fr_FR"
      end

      LolDataFetcher.reset!

      expect(LolDataFetcher.configuration.default_language).to eq("en_US")
    end

    it "clears the memoized client" do
      client1 = LolDataFetcher.client
      LolDataFetcher.reset!
      client2 = LolDataFetcher.client

      expect(client1.object_id).not_to eq(client2.object_id)
    end
  end
end
