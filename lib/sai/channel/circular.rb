# frozen_string_literal: true

module Sai
  class Channel
    class Circular < Channel
      def initialize(**options)
        super

        return if boundary.bound?

        raise ArgumentError, "`:bounds` is invalid. Expected a Range[Numeric], got: #{options[:bounds].inspect}"
      end

      def contract(value, scalar)
        (value / scalar) % FRACTION_RANGE.end
      end

      def decrement(value, amount)
        (value - amount) % FRACTION_RANGE.end
      end

      def denormalize(value)
        normalized = value % FRACTION_RANGE.end
        (normalized * boundary.width) + boundary.min
      end

      def exponentiate(value, exponent)
        (value**exponent) % FRACTION_RANGE.end
      end

      def increment(value, amount)
        (value + amount) % FRACTION_RANGE.end
      end

      def normalize(value)
        normalized = ((value - boundary.min) / boundary.width) % FRACTION_RANGE.end
        normalized.negative? ? normalized + FRACTION_RANGE.end : normalized
      end

      def scale(value, scalar)
        (value * scalar) % FRACTION_RANGE.end
      end
    end
  end
end
