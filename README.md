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

### Enumerable

Enum classes include `Enumerable`, so you can iterate, map, select, etc.:

```ruby
Status.each { |member| puts member.name }
Status.map(&:name)                # => [:draft, :published, :archived]
Status.select { |m| m.ordinal > 0 } # => [PUBLISHED, ARCHIVED]
Status.to_a                       # => [DRAFT, PUBLISHED, ARCHIVED]
Status.min                        # => DRAFT
```

### Collection Methods

```ruby
Status.to_h              # => { draft: nil, published: nil, archived: nil }
HttpCode.to_h            # => { ok: 200, not_found: 404, server_error: 500 }
HttpCode.members_by_value # => { 200 => OK, 404 => NOT_FOUND, 500 => SERVER_ERROR }
Status.size              # => 3
Status.count             # => 3
```

### Strict Lookup

`fetch` and `fetch_by_value` raise an error instead of returning `nil`:

```ruby
Status.fetch(:draft)          # => Status::DRAFT
Status.fetch(:unknown)        # raises Philiprehberger::Enum::Error
HttpCode.fetch_by_value(200)  # => HttpCode::OK
HttpCode.fetch_by_value(999)  # raises Philiprehberger::Enum::Error
```

### Names, Values, First & Last

```ruby
HttpCode.names   # => [:ok, :not_found, :server_error]
HttpCode.values  # => [200, 404, 500]
Status.first     # => Status::DRAFT
Status.last      # => Status::ARCHIVED
```

### Case-Insensitive Lookup

`from_name` tries an exact match first, then falls back to case-insensitive:

```ruby
Status.from_name(:draft)    # => Status::DRAFT (exact match)
Status.from_name("DRAFT")   # => Status::DRAFT (case-insensitive)
Status.from_name("Draft")   # => Status::DRAFT (case-insensitive)
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
| `.each` | Yield each member (includes `Enumerable`) |
| `.to_h` | Return `{ name_symbol => value }` hash |
| `.members_by_value` | Return `{ value => member }` reverse lookup hash |
| `.size` / `.count` | Return the number of defined members |
| `.names` | Return a frozen array of member name symbols |
| `.values` | Return a frozen array of member values |
| `.first` / `.last` | Return the first or last declared member |
| `.fetch(name)` | Strict lookup by name; raises `Error` if not found |
| `.fetch_by_value(val)` | Strict lookup by value; raises `Error` if not found |
| `.from_name(name)` | Look up by name (case-insensitive fallback) |
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
