# frozen_string_literal: true

module Sai
  class Observer
    class ColorMatchingFunction < WavelengthRange
      def initialize(wavelengths)
        unless wavelengths.values.all? { |v| (v.is_a?(Array) && v.all?(Numeric) && v.size == 3) || v.is_a?(Model::XYZ) }
          raise TypeError, '`wavelengths` is invalid. Expected ' \
                           "`Hash[Integer, [Numeric, Numeric, Numeric] | Model::XYZ]`, got: #{wavelengths.inspect}"
        end

        super(wavelengths.transform_values { |v| v.is_a?(Model::XYZ) ? v : Model::XYZ.new(*v) })
      end
    end
  end
end
