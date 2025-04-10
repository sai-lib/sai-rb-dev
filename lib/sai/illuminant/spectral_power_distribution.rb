# frozen_string_literal: true

module Sai
  class Illuminant
    class SpectralPowerDistribution < WavelengthRange
      def initialize(wavelengths)
        unless wavelengths.values.all?(Numeric)
          raise TypeError, "`wavelengths` is invalid. Expected `Hash[Integer, Numeric]`, got: #{wavelengths.inspect}"
        end

        super
      end
    end
  end
end
