# frozen_string_literal: true

module Sai
  class Model
    class HSV < Model
      channel :hue, :h, :hue_angle
      channel :saturation, :s, :percentage
      channel :value, :v, :percentage
      alias b v
      alias brightness value
      alias contract_brightness with_value_contracted_by
      alias decrement_brightness with_value_decremented_by
      alias increment_brightness with_value_incremented_by
      alias scale_brightness with_value_scaled_by
      alias with_brightness_contracted_by with_value_contracted_by
      alias with_brightness_decremented_by with_value_decremented_by
      alias with_brightness_incremented_by with_value_incremented_by
      alias with_brightness_scaled_by with_value_scaled_by
    end

    HSB = HSV
  end
end
