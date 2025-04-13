# frozen_string_literal: true

module Sai
  module Formula
    module Contrast
      module APCA
        BLACK_CLAMP_EXPONENT = 1.414
        BLACK_THRESHOLD = 0.022
        DEFAULT_BODY_TEXT_THRESHOLD = 60.0
        DEFAULT_LARGE_TEXT_THRESHOLD = 45.0
        DEFAULT_VERY_LARGE_TEXT_THRESHOLD = 30.0
        NORMALIZATION_HIGHER = 0.56
        NORMALIZATION_LOWER = 0.57
        SCALING_HIGHER = 0.62
        SCALING_LOWER = 0.57

        class << self
          def calculate(color1, color2, **options)
            [color1, color2].each do |color|
              next if color.is_a?(Model)

              raise TypeError, "color is invalid. Expected `Sai::Model`, got: #{color.inspect}"
            end

            l1, l2 = luminance = [
              color1.to_xyz(**options).y.normalized,
              color2.to_xyz(**options).y.normalized,
            ].freeze

            higher_luminance = luminance.max
            lower_luminance = luminance.min

            higher_clipped = if higher_luminance < BLACK_THRESHOLD
                               higher_luminance + ((BLACK_THRESHOLD - higher_luminance)**BLACK_CLAMP_EXPONENT)
                             else
                               higher_luminance
                             end

            higher_processed = higher_clipped**NORMALIZATION_HIGHER
            higher_scaled = higher_processed**SCALING_HIGHER

            lower_processed = lower_luminance**NORMALIZATION_LOWER
            raw_contrast = (higher_scaled - (higher_processed * lower_processed)) * 100.0

            l1 > l2 ? -raw_contrast : raw_contrast
          end
        end
      end
    end
  end
end
