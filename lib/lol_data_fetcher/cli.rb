# frozen_string_literal: true

require "thor"

module LolDataFetcher
  # Command-line interface for LolDataFetcher
  class CLI < Thor
    def self.exit_on_failure?
      true
    end

    desc "version", "Display the gem version"
    def version
      puts "lol_data_fetcher version #{LolDataFetcher::VERSION}"
    end

    desc "latest_version", "Show the latest game version"
    def latest_version
      client = LolDataFetcher::Client.new
      puts "Latest Data Dragon version: #{client.version}"
    rescue LolDataFetcher::Error => e
      error("Failed to fetch latest version: #{e.message}")
    end

    desc "champions", "List all champions"
    method_option :version, aliases: "-v", desc: "Game version to use"
    method_option :language, aliases: "-l", default: "en_US", desc: "Language code (e.g., en_US, ko_KR)"
    method_option :limit, aliases: "-n", type: :numeric, desc: "Limit number of results"
    def champions
      client = create_client
      data = client.champions.all

      champions = data["data"].values
      champions = champions.first(options[:limit]) if options[:limit]

      champions.each do |champion|
        puts format_champion(champion)
      end

      puts "\nTotal: #{champions.length} champions"
    rescue LolDataFetcher::Error => e
      error("Failed to fetch champions: #{e.message}")
    end

    desc "champion NAME", "Get details for a specific champion"
    method_option :version, aliases: "-v", desc: "Game version to use"
    method_option :language, aliases: "-l", default: "en_US", desc: "Language code"
    method_option :skills, aliases: "-s", type: :boolean, default: true, desc: "Show champion skills"
    method_option :skins, type: :boolean, default: false, desc: "Show champion skins"
    def champion(name)
      client = create_client
      data = client.champions.find(name)

      # Extract the normalized champion name from the response
      normalized_name = data.dig("data")&.keys&.first
      champion_data = data.dig("data", normalized_name)

      unless champion_data
        error("Champion '#{name}' not found")
        return
      end

      puts "\n#{champion_data['name']} - #{champion_data['title']}"
      puts "=" * 50
      puts "\nLore:"
      puts word_wrap(champion_data["lore"])

      if options[:skills]
        # Display passive ability
        if champion_data["passive"]
          passive = champion_data["passive"]
          puts "\nPassive: #{passive['name']}"
          puts "   #{word_wrap(strip_html(passive['description']), 3)}"
        end

        # Display active spells/abilities
        if champion_data["spells"]
          puts "\n#{champion_data['name']}'s Skills:"
          puts "-" * 50
          champion_data["spells"].each_with_index do |spell, idx|
            puts "\n#{idx + 1}. #{spell['name']}"
            puts "   #{word_wrap(strip_html(spell['description']), 3)}"
          end
        end
      end

      if options[:skins]
        puts "\n#{champion_data['name']}'s Skins:"
        puts "-" * 50
        skins = client.skins.for_champion(name)
        skins.each do |skin|
          puts "  - #{skin['name']}"
        end
      end
    rescue LolDataFetcher::NotFoundError => e
      error("Champion not found: #{e.message}")
    rescue LolDataFetcher::Error => e
      error("Failed to fetch champion: #{e.message}")
    end

    desc "items", "List all items"
    method_option :version, aliases: "-v", desc: "Game version to use"
    method_option :language, aliases: "-l", default: "en_US", desc: "Language code"
    method_option :search, aliases: "-s", desc: "Search items by name"
    method_option :limit, aliases: "-n", type: :numeric, desc: "Limit number of results"
    def items
      client = create_client

      if options[:search]
        items_list = client.items.search(options[:search])
      else
        data = client.items.all
        items_list = data["data"].values
      end

      items_list = items_list.first(options[:limit]) if options[:limit]

      items_list.each do |item|
        gold = item.dig("gold", "total") || 0
        puts "#{item['name']} - #{gold}g"
      end

      puts "\nTotal: #{items_list.length} items"
    rescue LolDataFetcher::Error => e
      error("Failed to fetch items: #{e.message}")
    end

    desc "summoner_spells", "List all summoner spells"
    method_option :version, aliases: "-v", desc: "Game version to use"
    method_option :language, aliases: "-l", default: "en_US", desc: "Language code"
    method_option :search, aliases: "-s", desc: "Search summoner spells by name"
    method_option :limit, aliases: "-n", type: :numeric, desc: "Limit number of results"
    def summoner_spells
      client = create_client

      if options[:search]
        spells_list = client.summoner_spells.search(options[:search])
      else
        data = client.summoner_spells.all
        spells_list = data["data"].values
      end

      spells_list = spells_list.first(options[:limit]) if options[:limit]

      spells_list.each do |spell|
        puts "#{spell['name'].ljust(20)} - #{strip_html(spell['description'])}"
      end

      puts "\nTotal: #{spells_list.length} summoner spells"
    rescue LolDataFetcher::Error => e
      error("Failed to fetch summoner spells: #{e.message}")
    end

    desc "skins CHAMPION", "List all skins for a champion"
    method_option :version, aliases: "-v", desc: "Game version to use"
    method_option :language, aliases: "-l", default: "en_US", desc: "Language code"
    method_option :urls, aliases: "-u", type: :boolean, default: false, desc: "Show image URLs"
    def skins(champion_name)
      client = create_client
      skins = client.skins.for_champion(champion_name)

      # Get the correctly-cased champion name from the first skin's URL if available
      # Or fetch it directly from the champions resource
      champion_data = client.champions.find(champion_name)
      normalized_name = champion_data.dig("data")&.keys&.first || champion_name

      puts "\n#{normalized_name}'s Skins:"
      puts "=" * 50

      skins.each do |skin|
        puts "\n#{skin['name']}"
        if options[:urls]
          puts "  Splash: #{skin['splash_url']}"
          puts "  Loading: #{skin['loading_url']}"
        end
      end

      puts "\nTotal: #{skins.length} skins"
    rescue LolDataFetcher::NotFoundError => e
      error("Champion not found: #{e.message}")
    rescue LolDataFetcher::Error => e
      error("Failed to fetch skins: #{e.message}")
    end

    private

    def create_client
      LolDataFetcher::Client.new(
        version: options[:version],
        language: options[:language]
      )
    end

    def format_champion(champion)
      "#{champion['name'].ljust(20)} - #{champion['title']}"
    end

    def strip_html(text)
      text.gsub(/<[^>]*>/, "")
    end

    def word_wrap(text, indent = 0)
      return "" unless text

      prefix = " " * indent
      text.gsub(/(.{1,#{78 - indent}})(\s+|$)/, "#{prefix}\\1\n").strip
    end

    def error(message)
      warn "\nError: #{message}"
      exit 1
    end
  end
end
