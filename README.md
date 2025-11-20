# LolDataFetcher

A Ruby client for the League of Legends Data Dragon API. Fetch champions, items, skins, and other static game data with ease.

## Features

- Fetch all champions with detailed information including skills/spells
- Get all items and search by name
- Retrieve champion skins with image URLs
- **Case-insensitive search** for champions, items, and skins
- Support for multiple game versions and languages
- Command-line interface (CLI) for quick data access
- Comprehensive test coverage with RSpec
- VCR cassettes for fast, repeatable tests

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'lol_data_fetcher'
```

And then execute:

```bash
bundle install
```

Or install it yourself as:

```bash
gem install lol_data_fetcher
```

## Usage

### Ruby API

#### Basic Usage

```ruby
require 'lol_data_fetcher'

# Create a client (automatically fetches the latest version)
client = LolDataFetcher::Client.new

# Or specify a version and language
client = LolDataFetcher::Client.new(
  version: "15.23.1",
  language: "ko_KR"
)
```

#### Fetching Champions

```ruby
# Get all champions (overview)
champions = client.champions.all
champions["data"].each do |key, champion|
  puts "#{champion['name']}: #{champion['title']}"
end

# Get detailed champion data including skills
ahri = client.champions.find("Ahri")
ahri_data = ahri["data"]["Ahri"]

puts ahri_data["name"]  # => "Ahri"
puts ahri_data["title"] # => "the Nine-Tailed Fox"

# Case-insensitive search (works with any casing!)
client.champions.find("ahri")     # => Works!
client.champions.find("AHRI")     # => Works!
client.champions.find("DrAvEn")   # => Works!

# Access champion's passive ability
passive = ahri_data["passive"]
puts "#{passive['name']}: #{passive['description']}"

# Or use the helper method (also case-insensitive)
passive = client.champions.passive("ahri")
puts "#{passive['name']}: #{passive['description']}"

# Access champion spells/skills
ahri_data["spells"].each do |spell|
  puts "#{spell['name']}: #{spell['description']}"
end

# List all champion names
names = client.champions.list_names
# => ["Aatrox", "Ahri", "Akali", ...]

# Find champion by ID
champion = client.champions.find_by_id("103") # Ahri
```

#### Fetching Items

```ruby
# Get all items
items = client.items.all
items["data"].each do |id, item|
  puts "#{item['name']} - #{item['gold']['total']}g"
end

# Find specific item by ID
boots = client.items.find("1001")
puts boots["name"] # => "Boots"

# Find item by name (case-insensitive exact match)
boots = client.items.find_by_name("boots")  # Works with any casing
puts boots["name"] # => "Boots"

# Search items by name (case-insensitive partial match)
swords = client.items.search("SWORD")  # Case doesn't matter
swords.each do |item|
  puts item["name"]
end

# List all item IDs
ids = client.items.list_ids
```

#### Fetching Skins

```ruby
# Get all skins for a specific champion (case-insensitive)
skins = client.skins.for_champion("ahri")  # Works with any casing
skins.each do |skin|
  puts skin["name"]
  puts "Splash: #{skin['splash_url']}"
  puts "Loading: #{skin['loading_url']}"
end
```

#### Version Management

```ruby
# Get all available versions
versions = client.versions.all
# => ["15.23.1", "15.23.0", ...]

# Get the latest version
latest = client.versions.latest
# => "15.23.1"

# Check if a version exists
client.versions.exists?("15.23.1") # => true
```

#### Global Configuration

```ruby
# Configure default settings
LolDataFetcher.configure do |config|
  config.default_language = "ja_JP"
  config.default_version = "15.23.1"
  config.timeout = 15
end

# Use the configured client
client = LolDataFetcher.client

# Reset configuration
LolDataFetcher.reset!
```

### Command Line Interface

The gem includes a powerful CLI for quick data access.

#### View Help

```bash
lol_data_fetcher help
```

#### Get Version Information

```bash
# Gem version
lol_data_fetcher version

# Latest Data Dragon version
lol_data_fetcher latest_version
```

#### List Champions

```bash
# List all champions
lol_data_fetcher champions

# Limit results
lol_data_fetcher champions --limit 10

# Use specific version and language
lol_data_fetcher champions -v 15.23.1 -l ko_KR
```

#### Get Champion Details

```bash
# Get champion info with skills
lol_data_fetcher champion Ahri

# Without skills
lol_data_fetcher champion Ahri --no-skills

# With skins
lol_data_fetcher champion Ahri --skins

# Use specific version
lol_data_fetcher champion Ahri -v 15.23.1
```

#### List Items

```bash
# List all items
lol_data_fetcher items

# Search items
lol_data_fetcher items --search "sword"

# Limit results
lol_data_fetcher items --limit 20

# Use specific version
lol_data_fetcher items -v 15.23.1 -l es_ES
```

#### Get Champion Skins

```bash
# List skins for a champion
lol_data_fetcher skins Ahri

# Show image URLs
lol_data_fetcher skins Ahri --urls
```

### Available Languages

The Data Dragon API supports multiple languages:
- `en_US` - English (United States)
- `ko_KR` - Korean
- `ja_JP` - Japanese
- `es_ES` - Spanish (Spain)
- `es_MX` - Spanish (Mexico)
- `fr_FR` - French
- `de_DE` - German
- `it_IT` - Italian
- `pl_PL` - Polish
- `pt_BR` - Portuguese (Brazil)
- `ru_RU` - Russian
- `tr_TR` - Turkish
- `zh_CN` - Chinese (China)
- `zh_TW` - Chinese (Taiwan)

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## API Reference

### Client

The main client class for interacting with the Data Dragon API.

```ruby
client = LolDataFetcher::Client.new(version: "15.23.1", language: "en_US")
```

**Methods:**
- `champions` - Access the Champions resource
- `items` - Access the Items resource
- `skins` - Access the Skins resource
- `versions` - Access the Versions resource

### Champions Resource

All champion name searches are **case-insensitive**.

```ruby
client.champions.all                  # Get all champions (overview)
client.champions.find("ahri")         # Get detailed champion data (case-insensitive)
client.champions.passive("AHRI")      # Get champion's passive ability (case-insensitive)
client.champions.list_names           # List all champion names
client.champions.find_by_id("103")    # Find champion by ID
```

### Items Resource

Item searches are **case-insensitive**.

```ruby
client.items.all                      # Get all items
client.items.find("1001")             # Find item by ID
client.items.find_by_name("boots")    # Find item by name (case-insensitive)
client.items.list_ids                 # List all item IDs
client.items.search("SWORD")          # Search items by name (case-insensitive)
```

### Skins Resource

Champion name searches are **case-insensitive**.

```ruby
client.skins.for_champion("ahri")     # Get skins for a champion (case-insensitive)
```

### Versions Resource

```ruby
client.versions.all                   # Get all available versions
client.versions.latest                # Get latest version
client.versions.exists?("15.23.1")    # Check if version exists
```

## Error Handling

The gem defines several error classes:

- `LolDataFetcher::Error` - Base error class
- `LolDataFetcher::ApiError` - API request failures
- `LolDataFetcher::NotFoundError` - Resource not found
- `LolDataFetcher::ConfigurationError` - Configuration issues

```ruby
begin
  client.champions.find("NonExistentChampion")
rescue LolDataFetcher::NotFoundError => e
  puts "Champion not found: #{e.message}"
rescue LolDataFetcher::ApiError => e
  puts "API error: #{e.message}"
end
```

## Testing

The gem uses RSpec for testing with VCR for recording HTTP interactions:

```bash
# Run all tests
bundle exec rspec

# Run specific test file
bundle exec rspec spec/lol_data_fetcher/client_spec.rb

# Run with coverage report
bundle exec rspec
# Coverage report will be in coverage/index.html
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/markchavez/lol_data_fetcher.

1. Fork the repository
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
