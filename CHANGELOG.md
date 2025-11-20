# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2025-11-20

### Added
- Initial release of lol_data_fetcher gem
- Client class for interacting with League of Legends Data Dragon API
- Champions resource for fetching champion data and skills
- Items resource for fetching and searching items
- Skins resource for fetching champion skins with image URLs
- Versions resource for managing Data Dragon versions
- Configuration system for setting default language and version
- Thor-based CLI with commands for champions, items, skins, and versions
- Comprehensive RSpec test suite with VCR for HTTP recording
- Support for multiple languages (en_US, ko_KR, ja_JP, etc.)
- Error handling with custom exception classes
- Detailed README with usage examples
- SimpleCov integration for code coverage tracking

### Features
- Fetch all champions with detailed information
- Get champion skills and abilities
- Search items by name
- Retrieve champion skins with splash and loading screen URLs
- Support for all Data Dragon versions
- Command-line interface for quick data access
- 87.88% code coverage with automated tests
