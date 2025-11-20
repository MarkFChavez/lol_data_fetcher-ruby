# frozen_string_literal: true

require "spec_helper"

RSpec.describe LolDataFetcher::Resources::Items do
  let(:client) { LolDataFetcher::Client.new(version: "14.1.1") }
  let(:items) { described_class.new(client) }

  describe "#all", :vcr do
    it "returns all items data" do
      result = items.all

      expect(result).to be_a(Hash)
      expect(result["data"]).to be_a(Hash)
      expect(result["data"]).not_to be_empty
    end

    it "includes item information" do
      result = items.all
      first_item = result["data"].values.first

      expect(first_item).to have_key("name")
      expect(first_item).to have_key("gold")
    end
  end

  describe "#find", :vcr do
    it "returns specific item data by ID" do
      # Item ID 1001 is typically Boots
      result = items.find("1001")

      expect(result).to be_a(Hash)
      expect(result["name"]).to be_a(String)
    end

    it "returns nil for non-existent item" do
      result = items.find("99999")

      expect(result).to be_nil
    end
  end

  describe "#list_ids", :vcr do
    it "returns an array of item IDs" do
      result = items.list_ids

      expect(result).to be_an(Array)
      expect(result).not_to be_empty
      expect(result).to all(be_a(String))
    end
  end

  describe "#search", :vcr do
    it "finds items by name" do
      result = items.search("sword")

      expect(result).to be_an(Array)
      expect(result).not_to be_empty
      expect(result.first).to have_key("name")
    end

    it "returns empty array when no matches found" do
      result = items.search("xyznonexistent")

      expect(result).to be_an(Array)
      expect(result).to be_empty
    end

    it "is case insensitive" do
      result_lower = items.search("sword")
      result_upper = items.search("SWORD")

      expect(result_lower).to eq(result_upper)
    end
  end

  describe "#find_by_name", :vcr do
    it "finds item by exact name match" do
      result = items.find_by_name("Boots")

      expect(result).to be_a(Hash)
      expect(result["name"]).to eq("Boots")
    end

    it "is case insensitive" do
      result_lower = items.find_by_name("boots")
      result_upper = items.find_by_name("BOOTS")

      expect(result_lower).to eq(result_upper)
      expect(result_lower["name"]).to eq("Boots")
    end

    it "returns nil for non-existent item" do
      result = items.find_by_name("NonExistentItem")

      expect(result).to be_nil
    end
  end
end
