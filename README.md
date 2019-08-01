# philiprehberger-enum

[![Tests](https://github.com/philiprehberger/rb-enum/actions/workflows/ci.yml/badge.svg)](https://github.com/philiprehberger/rb-enum/actions/workflows/ci.yml)
[![Gem Version](https://badge.fury.io/rb/philiprehberger-enum.svg)](https://rubygems.org/gems/philiprehberger-enum)
[![Last updated](https://img.shields.io/github/last-commit/philiprehberger/rb-enum)](https://github.com/philiprehberger/rb-enum/commits/main)

Type-safe enumerations with ordinals, custom values, and pattern matching

## Requirements

- Ruby >= 3.1

## Installation

Add to your Gemfile:

```ruby
gem "philiprehberger-enum"
```

Or install directly:

```bash
gem install philiprehberger-enum
```

## Usage

```ruby
require "philiprehberger/enum"

class Status < Philiprehberger::Enum
  member :draft
  member :published
  member :archived
end

Status::DRAFT.name       # => :draft
Status::DRAFT.ordinal    # => 0
Status.members           # => [DRAFT, PUBLISHED, ARCHIVED]
```

### Custom Values

```ruby
class HttpCode < Philiprehberger::Enum
  member :ok, value: 200
  member :not_found, value: 404
  member :server_error, value: 500
end

HttpCode::OK.value          # => 200
HttpCode.from_value(404)    # => HttpCode::NOT_FOUND
```

### Lookup Methods

```ruby
Status.from_name(:draft)    # => Status::DRAFT
Status.from_string('draft') # => Status::DRAFT
Status.valid?(:draft)       # => true
Status.valid?(:unknown)     # => false
```

### Comparison

Members are comparable by ordinal:

```ruby
Status::DRAFT < Status::PUBLISHED   # => true
Status.members.sort                  # sorted by declaration order
```

### Pattern Matching

```ruby
case Status::DRAFT
in { name: :draft }
  'is draft'
in { name: :published }
  'is published'
end
```

### Serialization

```ruby
Status::DRAFT.to_s     # => "draft"
Status::DRAFT.to_json  # => '{"name":"draft","ordinal":0,"value":null}'
```

## API

### `Philiprehberger::Enum` (base class)

| Method | Description |
|--------|-------------|
| `.member(name, value: nil)` | Define a new enum member with optional custom value |
| `.members` | Return all members in declaration order |
| `.from_name(name)` | Look up a member by symbol or string name |
| `.from_string(string)` | Look up a member by string name |
| `.from_value(val)` | Look up a member by custom value |
| `.valid?(name)` | Check if a name is a valid member |
| `#name` | Return the member name as a symbol |
| `#ordinal` | Return the ordinal position |
| `#value` | Return the custom value, or nil |
| `#to_s` | Return the member name as a string |
| `#to_json` | Serialize to JSON with name, ordinal, and value |
| `#deconstruct_keys(keys)` | Pattern matching support |
| `#<=>(other)` | Compare by ordinal |

## Development

```bash
bundle install
bundle exec rspec
bundle exec rubocop
```

## Support

If you find this project useful:

⭐ [Star the repo](https://github.com/philiprehberger/rb-enum)

🐛 [Report issues](https://github.com/philiprehberger/rb-enum/issues?q=is%3Aissue+is%3Aopen+label%3Abug)

💡 [Suggest features](https://github.com/philiprehberger/rb-enum/issues?q=is%3Aissue+is%3Aopen+label%3Aenhancement)

❤️ [Sponsor development](https://github.com/sponsors/philiprehberger)

🌐 [All Open Source Projects](https://philiprehberger.com/open-source-packages)

💻 [GitHub Profile](https://github.com/philiprehberger)

🔗 [LinkedIn Profile](https://www.linkedin.com/in/philiprehberger)

## License

[MIT](LICENSE)
