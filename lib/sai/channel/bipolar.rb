# frozen_string_literal: true

module Sai
  class Channel
    class Bipolar < Channel
      def contract(value, scalar)
        if boundary.unbound?
          value / scalar
        else
          (value - boundary.center) / (scalar + boundary.center)
        end
      end

      def decrement(value, amount)
        value - amount
      end

      def denormalize(value)
        return value if boundary.unbound?

        boundary.min + (value * boundary.width)
      end

      def exponentiate(value, exponent)
        if boundary.unbound?
          value**exponent
        else
          ((value - boundary.center)**exponent) + boundary.center
        end
      end

      def increment(value, amount)
        value + amount
      end

      def normalize(value)
        return value if boundary.unbound?

        (value - boundary.min) / boundary.width
      end

      def scale(value, scalar)
        if boundary.unbound?
          value * scalar
        else
          (value - boundary.center) * scalar
        end
      end
    end
  end
end
