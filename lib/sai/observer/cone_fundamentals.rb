# frozen_string_literal: true

module Sai
  class Observer
    class ConeFundamentals < WavelengthRange
      def initialize(wavelengths)
        unless wavelengths.values.all? { |v| (v.is_a?(Array) && v.all?(Numeric) && v.size == 3) || v.is_a?(Model::LMS) }
          raise TypeError, '`wavelengths` is invalid. Expected ' \
                           "`Hash[Integer, [Numeric, Numeric, Numeric] | Model::LMS]`, got: #{wavelengths.inspect}"
        end

        super(wavelengths.transform_values { |v| v.is_a?(Model::LMS) ? v : Model::LMS.new(*v) })
      end
    end
  end
end
