# frozen_string_literal: true

module Sai
  module Formula
    module CorrelatedColorTemperature
      module McCamy
        CONSTANT_TERM = 5520.33
        private_constant :CONSTANT_TERM

        CUBIC_COEFFICIENT = 449.0
        private_constant :CUBIC_COEFFICIENT

        LINEAR_COEFFICIENT = 6823.3
        private_constant :LINEAR_COEFFICIENT

        SQUARE_COEFFICIENT = 3525.0
        private_constant :SQUARE_COEFFICIENT

        EPICENTER_X = 0.3320
        private_constant :EPICENTER_X

        EPICENTER_Y = 0.1858
        private_constant :EPICENTER_Y

        VALID_RANGE = 2000..12_500
        private_constant :VALID_RANGE

        class << self
          def calculate(chromaticity)
            unless chromaticity.is_a?(Chromaticity)
              raise TypeError, "`chromaticity` is invalid. Expected `Sai::Chromaticity`, got: #{chromaticity.inspect}"
            end

            Sai.cache.fetch(McCamy, :calculate, *chromaticity.channel_cache_key) do
              x, y = chromaticity.to_a

              return nil if y == EPICENTER_Y

              n = (x - EPICENTER_X) / (y - EPICENTER_Y)

              cct = (CUBIC_COEFFICIENT * (n**3)) +
                    (SQUARE_COEFFICIENT * (n**2)) +
                    (LINEAR_COEFFICIENT * n) +
                    CONSTANT_TERM

              cct.round
            end
          end

          def within_valid_range?(cct)
            VALID_RANGE.include?(cct)
          end
        end
      end
    end
  end
end
