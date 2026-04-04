# frozen_string_literal: true

require_relative 'enum/version'
require 'json'

module Philiprehberger
  # Type-safe enumerations with ordinals, custom values, and pattern matching.
  #
  # Subclass Enum and use the `member` class method to define members:
  #
  #   class Status < Philiprehberger::Enum
  #     member :draft
  #     member :published
  #     member :archived
  #   end
  #
  class Enum
    include Comparable

    class Error < StandardError; end

    # @return [Symbol] the member name
    attr_reader :name

    # @return [Integer] the ordinal position (declaration order)
    attr_reader :ordinal

    # @return [Object, nil] the custom value, or nil if not set
    attr_reader :value

    # @param name [Symbol] the member name
    # @param ordinal [Integer] the ordinal position
    # @param value [Object, nil] an optional custom value
    def initialize(name, ordinal, value)
      @name = name
      @ordinal = ordinal
      @value = value
      freeze
    end

    # Compare members by ordinal
    #
    # @param other [Enum] another member of the same enum class
    # @return [Integer, nil] -1, 0, 1, or nil if not comparable
    def <=>(other)
      return nil unless other.is_a?(self.class)

      ordinal <=> other.ordinal
    end

    # @return [String] the member name as a string
    def to_s
      name.to_s
    end

    # @return [String] a human-readable representation
    def inspect
      "#<#{self.class} #{name}>"
    end

    # Serialize to a JSON-compatible hash
    #
    # @return [String] JSON string with name, ordinal, and value
    def to_json(*args)
      { name: name, ordinal: ordinal, value: value }.to_json(*args)
    end

    # Support Ruby 3.x pattern matching with `in` expressions
    #
    # @param keys [Array<Symbol>, nil] the keys to deconstruct
    # @return [Hash] hash of requested keys
    def deconstruct_keys(keys)
      h = { name: name, ordinal: ordinal, value: value }
      keys ? h.slice(*keys) : h
    end

    class << self
      include Enumerable

      # Yield each member in declaration order
      #
      # @yield [Enum] each member
      # @return [Enumerator] if no block given
      def each(&)
        freeze_members!
        member_registry.values.each(&)
      end

      # Define a new member on this enum class
      #
      # @param name [Symbol] the member name
      # @param value [Object, nil] an optional custom value
      # @return [Enum] the created member
      # @raise [Error] if the enum is frozen or name is already defined
      def member(name, value: nil)
        raise Error, "cannot add members to #{self} after freeze" if @frozen

        name = name.to_sym
        raise Error, "member #{name} is already defined on #{self}" if member_registry.key?(name)

        ord = member_registry.size
        instance = new(name, ord, value)

        member_registry[name] = instance
        const_set(name.upcase, instance)

        instance
      end

      # Return all members in declaration order
      #
      # @return [Array<Enum>] frozen array of all members
      def members
        freeze_members!
        member_registry.values.freeze
      end

      # Return a hash of name symbols to values
      #
      # @return [Hash{Symbol => Object}] name => value pairs
      def to_h
        freeze_members!
        member_registry.transform_values(&:value)
      end

      # Return a reverse lookup hash of values to members
      #
      # @return [Hash{Object => Enum}] value => member pairs
      def members_by_value
        freeze_members!
        member_registry.each_value.to_h { |m| [m.value, m] }
      end

      # Return the number of defined members
      #
      # @return [Integer] the member count
      def size
        freeze_members!
        member_registry.size
      end

      alias count size

      # Look up a member by its name, with case-insensitive fallback
      #
      # @param name [Symbol, String] the member name
      # @return [Enum, nil] the member, or nil if not found
      def from_name(name)
        freeze_members!
        key = name.to_sym
        member_registry[key] || member_registry.values.find { |m| m.name.to_s.downcase == key.to_s.downcase }
      end

      # Look up a member by its string representation
      #
      # @param string [String] the member name as a string
      # @return [Enum, nil] the member, or nil if not found
      def from_string(string)
        from_name(string)
      end

      # Look up a member by its custom value
      #
      # @param val [Object] the value to search for
      # @return [Enum, nil] the member, or nil if not found
      def from_value(val)
        freeze_members!
        member_registry.values.find { |m| m.value == val }
      end

      # Check if a name is a valid member
      #
      # @param name [Symbol, String] the member name
      # @return [Boolean] true if the name is a valid member
      def valid?(name)
        freeze_members!
        member_registry.key?(name.to_sym)
      end

      private

      def inherited(subclass)
        super
        subclass.instance_variable_set(:@member_registry, {})
        subclass.instance_variable_set(:@frozen, false)
      end

      def member_registry
        @member_registry ||= {}
      end

      def freeze_members!
        @frozen = true
      end
    end
  end
end
