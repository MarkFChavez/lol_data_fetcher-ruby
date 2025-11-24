# frozen_string_literal: true

require "spec_helper"

RSpec.describe LolDataFetcher::Resources::SummonerSpells do
  let(:client) { LolDataFetcher::Client.new(version: "14.1.1") }
  let(:summoner_spells) { described_class.new(client) }

  describe "#all", :vcr do
    it "returns all summoner spells data" do
      result = summoner_spells.all

      expect(result).to be_a(Hash)
      expect(result["data"]).to be_a(Hash)
      expect(result["data"]).not_to be_empty
    end

    it "includes summoner spell information" do
      result = summoner_spells.all
      first_spell = result["data"].values.first

      expect(first_spell).to have_key("name")
      expect(first_spell).to have_key("description")
    end
  end

  describe "#find", :vcr do
    it "returns specific summoner spell data by ID" do
      # SummonerFlash is the ID for Flash
      result = summoner_spells.find("SummonerFlash")

      expect(result).to be_a(Hash)
      expect(result["name"]).to be_a(String)
    end

    it "returns nil for non-existent summoner spell" do
      result = summoner_spells.find("NonExistentSpell")

      expect(result).to be_nil
    end
  end

  describe "#list_ids", :vcr do
    it "returns an array of summoner spell IDs" do
      result = summoner_spells.list_ids

      expect(result).to be_an(Array)
      expect(result).not_to be_empty
      expect(result).to all(be_a(String))
    end
  end

  describe "#search", :vcr do
    it "finds summoner spells by name" do
      result = summoner_spells.search("flash")

      expect(result).to be_an(Array)
      expect(result).not_to be_empty
      expect(result.first).to have_key("name")
    end

    it "returns empty array when no matches found" do
      result = summoner_spells.search("xyznonexistent")

      expect(result).to be_an(Array)
      expect(result).to be_empty
    end

    it "is case insensitive" do
      result_lower = summoner_spells.search("flash")
      result_upper = summoner_spells.search("FLASH")

      expect(result_lower).to eq(result_upper)
    end
  end

  describe "#find_by_name", :vcr do
    it "finds summoner spell by exact name match" do
      result = summoner_spells.find_by_name("Flash")

      expect(result).to be_a(Hash)
      expect(result["name"]).to eq("Flash")
    end

    it "is case insensitive" do
      result_lower = summoner_spells.find_by_name("flash")
      result_upper = summoner_spells.find_by_name("FLASH")

      expect(result_lower).to eq(result_upper)
      expect(result_lower["name"]).to eq("Flash")
    end

    it "returns nil for non-existent summoner spell" do
      result = summoner_spells.find_by_name("NonExistentSpell")

      expect(result).to be_nil
    end
  end
end
