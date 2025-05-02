# frozen_string_literal: true

module Sai
  module Space
    module Encoded
      class HSB < HSV
        alias b v
        alias brightness value
        alias contract_brightness with_value_contracted_by
        alias decrement_brightness with_value_decremented_by
        alias increment_brightness with_value_incremented_by
        alias scale_brightness with_value_scaled_by
        alias with_brightness with_value
        alias with_brightness_contracted_by with_value_contracted_by
        alias with_brightness_decremented_by with_value_decremented_by
        alias with_brightness_incremented_by with_value_incremented_by
        alias with_brightness_scaled_by with_value_scaled_by

        def to_hsb(...)
          convert_to_self(...)
        end

        def to_hsv(**options)
          convert_to_encoded(HSV, **options) { to_a }
        end
      end
    end
  end
end
