# frozen_string_literal: true

require_relative 'lib/philiprehberger/enum/version'

Gem::Specification.new do |spec|
  spec.name = 'philiprehberger-enum'
  spec.version = Philiprehberger::Enum::VERSION
  spec.authors = ['Philip Rehberger']
  spec.email = ['me@philiprehberger.com']

  spec.summary = 'Type-safe enumerations with ordinals, custom values, and pattern matching'
  spec.description = 'Define type-safe enums in Ruby with automatic ordinals, custom values, ' \
                       'lookup methods, and Ruby 3.x pattern matching support. A cleaner alternative ' \
                       'to ad-hoc constants and symbol sets.'
  spec.homepage = 'https://philiprehberger.com/open-source-packages/ruby/philiprehberger-enum'
  spec.license = 'MIT'

  spec.required_ruby_version = '>= 3.1.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/philiprehberger/rb-enum'
  spec.metadata['changelog_uri'] = 'https://github.com/philiprehberger/rb-enum/blob/main/CHANGELOG.md'
  spec.metadata['bug_tracker_uri'] = 'https://github.com/philiprehberger/rb-enum/issues'
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files = Dir['lib/**/*.rb', 'LICENSE', 'README.md', 'CHANGELOG.md']
  spec.require_paths = ['lib']
end
