# frozen_string_literal: true

module Sai
  module Formula
    module CorrelatedColorTemperature
      module HernandezAndres
        A0 = -949.86315
        private_constant :A0

        A1 = 6253.80338
        private_constant :A1

        A2 = 28.70599
        private_constant :A2

        A3 = 0.00004
        private_constant :A3

        T1 = 0.92159
        private_constant :T1

        T2 = 0.20039
        private_constant :T2

        T3 = 0.07125
        private_constant :T3

        EPICENTER_X = 0.3366
        private_constant :EPICENTER_X

        EPICENTER_Y = 0.1735
        private_constant :EPICENTER_Y

        VALID_RANGE = 3000..25_000
        private_constant :VALID_RANGE

        class << self
          include TypeFacade

          def calculate(chromaticity)
            unless chromaticity.is_a?(Chromaticity) ||
                   (chromaticity.is_a?(Array) && Chromaticity::XY.components.valid?(*chromaticity))
              raise TypeError, '`chromaticity` is invalid. Expected `Sai::Chromaticity | [Numeric, Numeric]`, ' \
                               "got: #{chromaticity.inspect}"
            end

            chromaticity = Chromaticity::XY.coerce(chromaticity)

            Sai.cache.fetch(HernandezAndres, :calculate, chromaticity.identity) do
              x, y = chromaticity.to_a

              return nil if y == EPICENTER_Y

              n = (x - EPICENTER_X) / (y - EPICENTER_Y)
              cct = A0 + (A1 * Math.exp(-n / T1)) + (A2 * Math.exp(-n / T2)) + (A3 * Math.exp(-n / T3))

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
