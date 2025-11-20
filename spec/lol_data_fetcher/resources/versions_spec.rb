# frozen_string_literal: true

require "spec_helper"

RSpec.describe LolDataFetcher::Resources::Versions do
  let(:client) { LolDataFetcher::Client.new(version: "14.1.1") }
  let(:versions) { described_class.new(client) }

  describe "#all", :vcr do
    it "returns an array of versions" do
      result = versions.all

      expect(result).to be_an(Array)
      expect(result).not_to be_empty
      expect(result.first).to be_a(String)
      expect(result.first).to match(/\d+\.\d+\.\d+/)
    end
  end

  describe "#latest", :vcr do
    it "returns the latest version string" do
      result = versions.latest

      expect(result).to be_a(String)
      expect(result).to match(/\d+\.\d+\.\d+/)
    end

    it "returns the first element from all versions" do
      allow(versions).to receive(:all).and_return(["14.1.1", "14.1.0", "13.24.1"])

      expect(versions.latest).to eq("14.1.1")
    end
  end

  describe "#exists?" do
    it "returns true for existing version", :vcr do
      all_versions = versions.all
      existing_version = all_versions.first

      expect(versions.exists?(existing_version)).to be true
    end

    it "returns false for non-existing version", :vcr do
      expect(versions.exists?("99.99.99")).to be false
    end
  end
end
