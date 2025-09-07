# Changelog

All notable changes to this gem will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.4.0] - 2026-04-16

### Added
- `Enum.slice(*names)` returns an array of members matching the given symbol names, silently skipping unknown names
- `Enum.sample(n = nil)` returns a random member when called without argument, or an array of n random members when called with an integer

## [0.3.0] - 2026-04-09

### Added
- `Enum.fetch(name)` strict lookup that raises `Error` if the name is not a member (case-insensitive fallback)
- `Enum.fetch_by_value(val)` strict value lookup that raises `Error` if no member has the given value
- `Enum.names` returns a frozen array of all member name symbols in declaration order
- `Enum.values` returns a frozen array of all member values in declaration order
- `Enum.first` / `Enum.last` return the first and last declared members

## [0.2.0] - 2026-04-03

### Added
- Include `Enumerable` at the class level with `each` yielding each member (`map`, `select`, `to_a`, etc.)
- `Enum.to_h` returns `{ name_symbol => value }` hash of all members
- `Enum.members_by_value` returns `{ value => member }` reverse lookup hash
- `Enum.size` / `Enum.count` returns the number of defined members

### Changed
- `Enum.from_name` now falls back to case-insensitive matching when exact match fails

## [0.1.6] - 2026-03-31

### Added
- Add GitHub issue templates, dependabot config, and PR template

## [0.1.5] - 2026-03-31

### Changed
- Standardize README badges, support section, and license format

## [0.1.4] - 2026-03-26

### Fixed
- Add Sponsor badge to README
- Fix license section link format

## [0.1.3] - 2026-03-24

### Fixed
- Standardize README code examples to use double-quote require statements
- Remove inline comments from Development section to match template

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
