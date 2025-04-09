# frozen_string_literal: true

module Sai
  class Observer
    class ChromaticityCoordinates < WavelengthRange
      def initialize(wavelengths)
        unless wavelengths.values.all? do |v|
          (v.is_a?(Array) && v.all?(Numeric) && v.size == 2) || v.is_a?(Chromaticity)
        end
          raise TypeError, '`wavelengths` is invalid. Expected ' \
                           "`Hash[Integer, [Numeric, Numeric] | Chromaticity]`, got: #{wavelengths.inspect}"
        end

        super(wavelengths.transform_values { |v| v.is_a?(Chromaticity) ? v : Chromaticity.new(*v) })
      end
    end
  end
end
