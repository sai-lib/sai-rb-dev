# frozen_string_literal: true

module Sai
  module Model
    module Component
      module Definition
        class Linear < Base
          def contract(value, scalar)
            value / scalar
          end

          def decrement(value, amount)
            value - amount
          end

          def denormalize(value)
            return value if boundary.unbound?

            (value * boundary.width) + boundary.min
          end

          def exponentiate(value, exponent)
            value**exponent
          end

          def increment(value, amount)
            value + amount
          end

          def normalize(value)
            return value if boundary.unbound?

            (value - boundary.min) / boundary.width
          end

          def scale(value, scalar)
            value * scalar
          end
        end
      end
    end
  end
end
