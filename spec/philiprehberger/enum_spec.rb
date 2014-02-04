# frozen_string_literal: true

require 'spec_helper'
require 'json'

# rubocop:disable Lint/ConstantDefinitionInBlock
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

    it 'considers equal ordinals as equal' do
      expect(priority_class::MEDIUM <=> priority_class::MEDIUM).to eq(0)
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
# rubocop:enable Lint/ConstantDefinitionInBlock
