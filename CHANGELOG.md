# Changelog

All notable changes to this gem will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.2] - 2026-03-24

### Fixed
- Fix Installation section quote style to double quotes

## [0.1.1] - 2026-03-22

### Changed
- Improve source code, tests, and rubocop compliance

## [0.1.0] - 2026-03-21

### Added

- Initial release
- Type-safe enum base class with `member` class method
- Automatic ordinals based on declaration order
- Custom values via `value:` keyword parameter
- Lookup methods: `from_name`, `from_value`, `from_string`, `valid?`
- Comparable by ordinal for sorting and comparison
- Pattern matching support via `deconstruct_keys`
- JSON serialization via `to_json`
- Frozen singleton members for immutability
