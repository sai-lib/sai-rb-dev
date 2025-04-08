# frozen_string_literal: true

module Sai
  class Channel
    class Value < Numeric
      attr_reader :normalized
      attr_reader :unnormalized

      def initialize(value, definition, normalized: false) # rubocop:disable Lint/MissingSuper
        @definition = definition

        if normalized
          @normalized = value
          @unnormalized = @definition.denormalize(value)
        else
          @normalized = @definition.normalize(value)
          @unnormalized = value
        end

        freeze
      end

      def *(other)
        @definition.scale(normalized, other)
      end

      def **(other)
        @definition.exponentiate(normalized, other)
      end

      def +(other)
        @definition.increment(normalized, other)
      end

      def +@
        self
      end

      def -(other)
        @definition.decrement(normalized, other)
      end

      def -@
        self.class.new(-normalized, @definition, normalized: true)
      end

      def /(other)
        @definition.contract(normalized, other)
      end

      def <=>(other)
        case other
        when Numeric then normalized <=> other
        when Value then normalized <=> other.normalized
        end
      end

      def ==(other)
        (other.is_a?(Numeric) && @definition.normalize(other) == normalized) ||
          (other.is_a?(self.class) && other.normalized == normalized)
      end

      def coerce(other)
        [other.to_f, normalized.to_f]
      end

      def inspect
        unnormalized.inspect
      end

      def normalized?
        unnormalized != normalized
      end

      def to_display
        unnormalized.round(@definition.display.precision)
      end

      def to_float
        unnormalized.to_f
      end
      alias to_f to_float

      def to_integer
        unnormalized.to_i
      end
      alias to_i to_integer

      def to_string
        @definition.display.format % unnormalized
      end
      alias to_s to_string
    end
  end
end
