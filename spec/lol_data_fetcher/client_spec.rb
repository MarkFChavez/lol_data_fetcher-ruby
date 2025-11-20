# frozen_string_literal: true

require "spec_helper"

RSpec.describe LolDataFetcher::Client do
  describe "#initialize" do
    it "uses provided version and language" do
      client = described_class.new(version: "14.1.1", language: "ko_KR")

      expect(client.version).to eq("14.1.1")
      expect(client.language).to eq("ko_KR")
    end

    it "uses default language from configuration" do
      LolDataFetcher.configure do |config|
        config.default_language = "ja_JP"
      end

      client = described_class.new(version: "14.1.1")

      expect(client.language).to eq("ja_JP")
    end

    it "fetches latest version when not provided", :vcr do
      client = described_class.new

      expect(client.version).to match(/\d+\.\d+\.\d+/)
    end
  end

  describe "resource accessors" do
    let(:client) { described_class.new(version: "14.1.1") }

    it "provides access to champions resource" do
      expect(client.champions).to be_a(LolDataFetcher::Resources::Champions)
    end

    it "provides access to items resource" do
      expect(client.items).to be_a(LolDataFetcher::Resources::Items)
    end

    it "provides access to skins resource" do
      expect(client.skins).to be_a(LolDataFetcher::Resources::Skins)
    end

    it "provides access to versions resource" do
      expect(client.versions).to be_a(LolDataFetcher::Resources::Versions)
    end

    it "memoizes resource instances" do
      expect(client.champions.object_id).to eq(client.champions.object_id)
    end
  end

  describe "#connection" do
    let(:client) { described_class.new(version: "14.1.1") }

    it "returns a Faraday connection" do
      expect(client.connection).to be_a(Faraday::Connection)
    end

    it "uses the correct base URL" do
      expect(client.connection.url_prefix.to_s).to eq("https://ddragon.leagueoflegends.com/")
    end

    it "memoizes the connection" do
      expect(client.connection.object_id).to eq(client.connection.object_id)
    end
  end
end
