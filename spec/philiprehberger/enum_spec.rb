# frozen_string_literal: true

require 'spec_helper'
require 'json'

RSpec.describe Philiprehberger::Enum do
  it 'has a version number' do
    expect(described_class::VERSION).not_to be_nil
  end

  describe 'member definition' do
    let(:status_class) do
      Class.new(described_class) do
        member :draft
        member :published
        member :archived
      end
    end

    it 'creates constant for each member' do
      expect(status_class::DRAFT).to be_a(status_class)
      expect(status_class::PUBLISHED).to be_a(status_class)
      expect(status_class::ARCHIVED).to be_a(status_class)
    end

    it 'assigns sequential ordinals' do
      expect(status_class::DRAFT.ordinal).to eq(0)
      expect(status_class::PUBLISHED.ordinal).to eq(1)
      expect(status_class::ARCHIVED.ordinal).to eq(2)
    end

    it 'assigns the correct name' do
      expect(status_class::DRAFT.name).to eq(:draft)
      expect(status_class::PUBLISHED.name).to eq(:published)
    end

    it 'returns nil value when no custom value is set' do
      expect(status_class::DRAFT.value).to be_nil
    end

    it 'returns the member name from to_s' do
      expect(status_class::DRAFT.to_s).to eq('draft')
    end

    it 'returns a readable inspect string' do
      expect(status_class::DRAFT.inspect).to include('draft')
    end

    it 'raises on duplicate member name' do
      expect do
        Class.new(described_class) do
          member :draft
          member :draft
        end
      end.to raise_error(described_class::Error, /already defined/)
    end
  end

  describe 'custom values' do
    let(:http_code_class) do
      Class.new(described_class) do
        member :ok, value: 200
        member :not_found, value: 404
        member :server_error, value: 500
      end
    end

    it 'stores the custom value' do
      expect(http_code_class::OK.value).to eq(200)
      expect(http_code_class::NOT_FOUND.value).to eq(404)
    end

    it 'looks up by value' do
      expect(http_code_class.from_value(404)).to eq(http_code_class::NOT_FOUND)
    end

    it 'returns nil for unknown value' do
      expect(http_code_class.from_value(999)).to be_nil
    end
  end

  describe '.members' do
    let(:color_class) do
      Class.new(described_class) do
        member :red
        member :green
        member :blue
      end
    end

    it 'returns all members in declaration order' do
      expect(color_class.members.map(&:name)).to eq(%i[red green blue])
    end

    it 'returns a frozen array' do
      expect(color_class.members).to be_frozen
    end
  end

  describe '.from_name' do
    let(:status_class) do
      Class.new(described_class) do
        member :active
        member :inactive
      end
    end

    it 'finds a member by symbol name' do
      expect(status_class.from_name(:active)).to eq(status_class::ACTIVE)
    end

    it 'finds a member by string name' do
      expect(status_class.from_name('inactive')).to eq(status_class::INACTIVE)
    end

    it 'returns nil for unknown name' do
      expect(status_class.from_name(:unknown)).to be_nil
    end
  end

  describe '.from_string' do
    let(:status_class) do
      Class.new(described_class) do
        member :pending
      end
    end

    it 'finds a member by string' do
      expect(status_class.from_string('pending')).to eq(status_class::PENDING)
    end
  end

  describe '.valid?' do
    let(:status_class) do
      Class.new(described_class) do
        member :open
        member :closed
      end
    end

    it 'returns true for valid member name' do
      expect(status_class.valid?(:open)).to be true
    end

    it 'returns true for valid string name' do
      expect(status_class.valid?('closed')).to be true
    end

    it 'returns false for unknown name' do
      expect(status_class.valid?(:unknown)).to be false
    end
  end

  describe 'comparison' do
    let(:priority_class) do
      Class.new(described_class) do
        member :low
        member :medium
        member :high
      end
    end

    it 'compares by ordinal' do
      expect(priority_class::LOW).to be < priority_class::HIGH
      expect(priority_class::HIGH).to be > priority_class::MEDIUM
    end

    it 'considers same member as equal' do
      member = priority_class::MEDIUM
      expect(member <=> member).to eq(0) # rubocop:disable Lint/BinaryOperatorWithIdenticalOperands
    end

    it 'returns nil when comparing different enum classes' do
      other_class = Class.new(described_class) { member :other }
      expect(priority_class::LOW <=> other_class::OTHER).to be_nil
    end

    it 'supports sorting' do
      members = [priority_class::HIGH, priority_class::LOW, priority_class::MEDIUM]
      expect(members.sort.map(&:name)).to eq(%i[low medium high])
    end
  end

  describe 'pattern matching' do
    let(:status_class) do
      Class.new(described_class) do
        member :draft, value: 0
        member :published, value: 1
      end
    end

    it 'supports deconstruct_keys with specific keys' do
      result = status_class::DRAFT.deconstruct_keys(%i[name ordinal])
      expect(result).to eq({ name: :draft, ordinal: 0 })
    end

    it 'supports deconstruct_keys with nil (all keys)' do
      result = status_class::PUBLISHED.deconstruct_keys(nil)
      expect(result).to eq({ name: :published, ordinal: 1, value: 1 })
    end

    it 'works with case/in pattern matching' do
      member = status_class::DRAFT

      matched = case member
                in { name: :draft }
                  'is draft'
                in { name: :published }
                  'is published'
                end

      expect(matched).to eq('is draft')
    end
  end

  describe 'immutability' do
    let(:status_class) do
      Class.new(described_class) do
        member :active
      end
    end

    it 'freezes each member' do
      expect(status_class::ACTIVE).to be_frozen
    end

    it 'prevents adding members after freeze' do
      status_class.members # triggers freeze

      expect do
        status_class.member(:new_member)
      end.to raise_error(described_class::Error, /cannot add members/)
    end
  end

  describe 'JSON serialization' do
    let(:status_class) do
      Class.new(described_class) do
        member :active, value: 'on'
      end
    end

    it 'serializes to JSON' do
      json = JSON.parse(status_class::ACTIVE.to_json)
      expect(json).to eq({ 'name' => 'active', 'ordinal' => 0, 'value' => 'on' })
    end
  end

  describe 'Enumerable support' do
    let(:color_class) do
      Class.new(described_class) do
        member :red, value: '#f00'
        member :green, value: '#0f0'
        member :blue, value: '#00f'
      end
    end

    it 'yields each member via each' do
      names = color_class.map(&:name)
      expect(names).to eq(%i[red green blue])
    end

    it 'supports map' do
      expect(color_class.map(&:name)).to eq(%i[red green blue])
    end

    it 'supports select' do
      result = color_class.select { |m| m.ordinal > 0 }
      expect(result.map(&:name)).to eq(%i[green blue])
    end

    it 'supports to_a' do
      expect(color_class.to_a.size).to eq(3)
      expect(color_class.to_a.first).to eq(color_class::RED)
    end

    it 'supports min and max' do
      expect(color_class.min).to eq(color_class::RED)
      expect(color_class.max).to eq(color_class::BLUE)
    end
  end

  describe '.to_h' do
    let(:http_class) do
      Class.new(described_class) do
        member :ok, value: 200
        member :not_found, value: 404
      end
    end

    it 'returns a hash of name symbols to values' do
      expect(http_class.to_h).to eq({ ok: 200, not_found: 404 })
    end

    it 'returns nil values for members without custom values' do
      klass = Class.new(described_class) { member :a }
      expect(klass.to_h).to eq({ a: nil })
    end
  end

  describe '.members_by_value' do
    let(:http_class) do
      Class.new(described_class) do
        member :ok, value: 200
        member :not_found, value: 404
      end
    end

    it 'returns a hash of values to members' do
      result = http_class.members_by_value
      expect(result[200]).to eq(http_class::OK)
      expect(result[404]).to eq(http_class::NOT_FOUND)
    end
  end

  describe '.size / .count' do
    let(:status_class) do
      Class.new(described_class) do
        member :a
        member :b
        member :c
      end
    end

    it 'returns the number of members via size' do
      expect(status_class.size).to eq(3)
    end

    it 'returns the number of members via count' do
      expect(status_class.count).to eq(3)
    end
  end

  describe 'case-insensitive from_name' do
    let(:status_class) do
      Class.new(described_class) do
        member :draft
        member :published
      end
    end

    it 'finds a member by exact name' do
      expect(status_class.from_name(:draft)).to eq(status_class::DRAFT)
    end

    it 'finds a member by uppercase string' do
      expect(status_class.from_name('DRAFT')).to eq(status_class::DRAFT)
    end

    it 'finds a member by mixed-case string' do
      expect(status_class.from_name('Draft')).to eq(status_class::DRAFT)
    end

    it 'returns nil for unknown name regardless of case' do
      expect(status_class.from_name('UNKNOWN')).to be_nil
    end
  end

  describe '.fetch' do
    let(:status_class) do
      Class.new(described_class) do
        member :draft
        member :published
      end
    end

    it 'returns a member by symbol name' do
      expect(status_class.fetch(:draft)).to eq(status_class::DRAFT)
    end

    it 'returns a member by string name' do
      expect(status_class.fetch('published')).to eq(status_class::PUBLISHED)
    end

    it 'returns a member via case-insensitive fallback' do
      expect(status_class.fetch('DRAFT')).to eq(status_class::DRAFT)
    end

    it 'raises Error for unknown name' do
      expect { status_class.fetch(:unknown) }.to raise_error(described_class::Error, /no member/)
    end
  end

  describe '.fetch_by_value' do
    let(:http_class) do
      Class.new(described_class) do
        member :ok, value: 200
        member :not_found, value: 404
      end
    end

    it 'returns a member by value' do
      expect(http_class.fetch_by_value(200)).to eq(http_class::OK)
    end

    it 'raises Error for unknown value' do
      expect { http_class.fetch_by_value(999) }.to raise_error(described_class::Error, /no member with value/)
    end
  end

  describe '.names / .values' do
    let(:http_class) do
      Class.new(described_class) do
        member :ok, value: 200
        member :not_found, value: 404
      end
    end

    it 'returns names in declaration order' do
      expect(http_class.names).to eq(%i[ok not_found])
    end

    it 'returns values in declaration order' do
      expect(http_class.values).to eq([200, 404])
    end

    it 'returns a frozen names array' do
      expect(http_class.names).to be_frozen
    end

    it 'returns a frozen values array' do
      expect(http_class.values).to be_frozen
    end
  end

  describe '.first / .last' do
    let(:status_class) do
      Class.new(described_class) do
        member :draft
        member :published
        member :archived
      end
    end

    it 'returns the first declared member' do
      expect(status_class.first).to eq(status_class::DRAFT)
    end

    it 'returns the last declared member' do
      expect(status_class.last).to eq(status_class::ARCHIVED)
    end
  end

  describe '.slice' do
    let(:status_class) do
      Class.new(described_class) do
        member :draft
        member :published
        member :archived
      end
    end

    it 'returns members matching the given names' do
      result = status_class.slice(:draft, :archived)
      expect(result).to eq([status_class::DRAFT, status_class::ARCHIVED])
    end

    it 'silently skips unknown names' do
      result = status_class.slice(:draft, :unknown)
      expect(result).to eq([status_class::DRAFT])
    end

    it 'returns an empty array when no names match' do
      expect(status_class.slice(:missing)).to eq([])
    end

    it 'returns members in the given argument order' do
      result = status_class.slice(:archived, :draft)
      expect(result.map(&:name)).to eq(%i[archived draft])
    end
  end

  describe '.sample' do
    let(:status_class) do
      Class.new(described_class) do
        member :draft
        member :published
        member :archived
      end
    end

    it 'returns a single member when called without argument' do
      result = status_class.sample
      expect(result).to be_a(status_class)
    end

    it 'returns a member that belongs to the enum' do
      expect(status_class.members).to include(status_class.sample)
    end

    it 'returns an array when called with an integer argument' do
      result = status_class.sample(2)
      expect(result).to be_an(Array)
      expect(result.size).to eq(2)
    end

    it 'returns only valid members when called with an argument' do
      result = status_class.sample(2)
      result.each { |m| expect(m).to be_a(status_class) }
    end

    it 'returns an empty array when 0 is given' do
      expect(status_class.sample(0)).to eq([])
    end
  end

  describe 'multiple enum classes' do
    let(:color_class) do
      Class.new(described_class) do
        member :red
        member :blue
      end
    end

    let(:size_class) do
      Class.new(described_class) do
        member :small
        member :large
      end
    end

    it 'keeps members separate between classes' do
      expect(color_class.members.map(&:name)).to eq(%i[red blue])
      expect(size_class.members.map(&:name)).to eq(%i[small large])
    end

    it 'does not share members' do
      expect(color_class.valid?(:small)).to be false
      expect(size_class.valid?(:red)).to be false
    end
  end
end
