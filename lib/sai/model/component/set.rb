# frozen_string_literal: true

module Sai
  module Model
    module Component
      class Set
        include Enumerable
        include Core::Identity

        def initialize(base, normalized: false, **components)
          @base = base

          @base.class.components.each do |definition|
            define_singleton_method(definition.identifier) { @components[definition.identifier] }

            unless definition.identifier == definition.name
              define_singleton_method(definition.name) { @components[definition.identifier] }
            end
          end

          @components = @base.class.components.each_with_object({}) do |definition, result|
            value = components.fetch(definition.identifier, components[definition.name])
            value = Value.new(value, definition, normalized:) unless value.is_a?(Value)
            result[definition.identifier] = value
          end
        end

        def ==(other)
          (other.is_a?(self.class) && other.identity == identity) ||
            (other.is_a?(Array) && other == to_normalized) ||
            (other.is_a?(Array) && other == to_unnormalized)
        end

        def [](index_identifier_or_name)
          case index_identifier_or_name
          when String, Symbol
            key = index_identifier_or_name.to_sym
            @components.fetch(key, @components[@base.class.components[key]&.identifier])
          when Integer
            @components.values[index_identifier_or_name]
          end
        end

        def each(&)
          @components.each_value(&)
          self
        end

        def each_pair(&)
          @components.each_pair(&)
          self
        end

        def to_normalized
          @components.values.map(&:normalized)
        end

        def to_string
          @components.values.map(&:to_string).join(', ')
        end

        def to_unnormalized
          @components.values.map(&:unnormalized)
        end

        def valid?
          @base.class.components.valid?(*to_unnormalized)
        end

        def with(base = @base, normalized: true, **components)
          new_components = base.class.components.each_with_object({}) do |definition, result|
            value = components.fetch(
              definition.identifier,
              components.fetch(definition.name, @components[definition.identifier]),
            )
            value = Value.new(value, definition, normalized:) unless value.is_a?(Value)
            result[definition.identifier] = value
          end

          self.class.new(base, normalized:, **new_components)
        end

        private

        def identity_attributes
          [@base.class, to_unnormalized].freeze
        end
      end
    end
  end
end
