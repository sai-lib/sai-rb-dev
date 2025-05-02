# frozen_string_literal: true

module Sai
  module Model
    module Component
      class Value < Numeric
        attr_reader :definition
        attr_reader :normalized
        attr_reader :unnormalized

        def initialize(value, definition, normalized: false) # rubocop:disable Lint/MissingSuper
          @definition = definition

          if value.is_a?(self.class)
            @normalized = value.normalized
            @unnormalized = value.unnormalized
          elsif normalized
            @normalized = value.to_f
            @unnormalized = definition.denormalize(value)
          else
            @normalized = definition.normalize(value).to_f
            @unnormalized = value
          end

          freeze
        end

        def *(other)
          self.class.new(definition.scale(normalized, other), definition, normalized: true)
        end

        def **(other)
          self.class.new(definition.exponentiate(normalized, other), definition, normalized: true)
        end

        def +(other)
          self.class.new(definition.increment(normalized, other), definition, normalized: true)
        end

        def +@
          self
        end

        def -(other)
          self.class.new(definition.decrement(normalized, other), definition, normalized: true)
        end

        def -@
          self.class.new(-normalized, definition, normalized: true)
        end

        def /(other)
          self.class.new(definition.contract(normalized, other), definition, normalized: true)
        end

        def <=>(other)
          normalized <=> (other.is_a?(Value) ? other.normalized : other)
        end

        def ==(other)
          (other.is_a?(Value) && other.normalized == normalized) ||
            (other.is_a?(Numeric) && definition.normalize(other) == normalized)
        end

        def coerce(other)
          [other.to_f, normalized]
        end

        def inspect
          unnormalized.inspect
        end

        def normalized?
          unnormalized != normalized
        end

        def to_display
          unnormalized.round(definition.display.precision)
        end

        def to_float
          normalized
        end
        alias to_f to_float

        def to_integer
          unnormalized.to_i
        end
        alias to_i to_integer

        def to_string
          definition.display.format % unnormalized
        end
        alias to_s to_string
      end
    end
  end
end
