# frozen_string_literal: true

module Sai
  module Model
    module Component
      module Definition
        class Set
          include Enumerable
          include Core::Concurrency
          include Core::Identity

          COMPONENT_TYPES = {
            circular: [Circular, EMPTY_HASH].freeze,
            hue_angle: [Circular, { bounds: 0.0..360.0, display_format: '%.0f°' }.freeze].freeze,
            linear: [Linear, EMPTY_HASH].freeze,
            opponent: [Opponent, EMPTY_HASH].freeze,
            percentage: [
              Linear,
              { bounds: PERCENTAGE_RANGE, differential_step: 0.005, display_format: '%.1f%%' }.freeze,
            ].freeze,
          }.freeze

          def initialize
            @definitions = EMPTY_HASH
            @index       = EMPTY_HASH
          end

          def ==(other)
            other.is_a?(self.class) && other.identity == identity
          end

          def [](index_identifier_or_name)
            case index_identifier_or_name
            when String, Symbol
              key = index_identifier_or_name.to_sym
              @definitions.fetch(key, @definitions[@index[key]])
            when Integer
              @definitions.values[index_identifier_or_name]
            end
          end

          def each(&)
            @definitions.values.each(&)
            self
          end

          def each_pair(&)
            @definitions.each_pair(&)
            self
          end

          def identifiers
            @definitions.keys
          end

          def length
            @definitions.length
          end
          alias size length

          def names
            @index.keys
          end

          def push(type:, **options)
            component_type, default_options = COMPONENT_TYPES[type]

            unless component_type
              raise ArgumentError, "`:type` is invalid. Expected one of #{COMPONENT_TYPES.keys.join(', ')} " \
                                   "got: #{type.inspect}"
            end

            options = default_options.merge(options)
            component = component_type.new(**options)

            mutex.synchronize do
              @definitions = @definitions.merge(component.identifier => component).freeze
              @index       = @index.merge(component.name => component.identifier).freeze

              define_singleton_method(component.identifier) { component }
              define_singleton_method(component.name) { component } unless component.identifier == component.name
            end

            component
          end
          alias << push

          def valid?(*components)
            return false if components.size < count(&:required?) || components.size > size

            map.with_index do |definition, index|
              value = components[index]
              next true if value.nil? && !definition.required?
              next false unless value.is_a?(Numeric)
              next true if definition.boundary.unbound?

              definition.boundary.range.cover?(value)
            end.all?
          end

          private

          def identity_attributes
            [
              self.class,
              *@definitions.values.map(&:identity),
            ]
          end
        end
      end
    end
  end
end
