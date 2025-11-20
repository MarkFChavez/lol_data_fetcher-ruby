# frozen_string_literal: true

require "spec_helper"

RSpec.describe LolDataFetcher::Resources::Champions do
  let(:client) { LolDataFetcher::Client.new(version: "14.1.1") }
  let(:champions) { described_class.new(client) }

  describe "#all", :vcr do
    it "returns all champions data" do
      result = champions.all

      expect(result).to be_a(Hash)
      expect(result["data"]).to be_a(Hash)
      expect(result["data"]).not_to be_empty
    end

    it "includes champion basic information" do
      result = champions.all
      first_champion = result["data"].values.first

      expect(first_champion).to have_key("name")
      expect(first_champion).to have_key("title")
      expect(first_champion).to have_key("key")
    end
  end

  describe "#find", :vcr do
    it "returns detailed champion data including skills" do
      result = champions.find("Ahri")

      expect(result).to be_a(Hash)
      expect(result["data"]).to have_key("Ahri")

      ahri_data = result["data"]["Ahri"]
      expect(ahri_data["name"]).to eq("Ahri")
      expect(ahri_data["spells"]).to be_an(Array)
      expect(ahri_data["spells"].length).to be > 0
    end

    it "includes spell/skill information" do
      result = champions.find("Ahri")
      first_spell = result["data"]["Ahri"]["spells"].first

      expect(first_spell).to have_key("name")
      expect(first_spell).to have_key("description")
    end

    it "includes passive ability information" do
      result = champions.find("Ahri")
      passive = result["data"]["Ahri"]["passive"]

      expect(passive).to be_a(Hash)
      expect(passive).to have_key("name")
      expect(passive).to have_key("description")
      expect(passive["name"]).to be_a(String)
      expect(passive["description"]).to be_a(String)
    end
  end

  describe "#passive", :vcr do
    it "returns the passive ability for a champion" do
      passive = champions.passive("Ahri")

      expect(passive).to be_a(Hash)
      expect(passive).to have_key("name")
      expect(passive).to have_key("description")
    end

    it "returns passive with expected structure" do
      passive = champions.passive("Draven")

      expect(passive["name"]).to eq("League of Draven")
      expect(passive["description"]).to include("Adoration")
    end
  end

  describe "#list_names", :vcr do
    it "returns an array of champion names" do
      result = champions.list_names

      expect(result).to be_an(Array)
      expect(result).not_to be_empty
      expect(result).to all(be_a(String))
    end
  end

  describe "#find_by_id", :vcr do
    it "finds champion by numeric ID" do
      # Ahri's ID is typically "103"
      result = champions.find_by_id("103")

      expect(result).to be_a(Hash)
      expect(result["key"]).to eq("103")
      expect(result["name"]).to eq("Ahri")
    end

    it "returns nil for non-existent ID" do
      result = champions.find_by_id("99999")

      expect(result).to be_nil
    end
  end
end
