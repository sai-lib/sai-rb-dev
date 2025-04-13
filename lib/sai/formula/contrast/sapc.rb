# frozen_string_literal: true

module Sai
  module Formula
    module Contrast
      module SAPC
        EXPONENT = 0.42
        SCALE_FACTOR = 1.14

        class << self
          def calculate(color1, color2, **options)
            [color1, color2].each do |color|
              next if color.is_a?(Model)

              raise TypeError, "color is invalid. Expected `Sai::Model`, got: #{color.inspect}"
            end

            l1, l2 = [
              color1.to_xyz(**options).y.normalized,
              color2.to_xyz(**options).y.normalized,
            ].freeze

            text_y, bg_y = l1 < l2 ? [l1, l2] : [l2, l1]

            text_y_p = text_y**EXPONENT
            bg_y_p = bg_y**EXPONENT

            raw_contrast = (bg_y_p - text_y_p) * SCALE_FACTOR * PERCENTAGE_RANGE.end

            l1 < l2 ? raw_contrast : -raw_contrast
          end
        end
      end
    end
  end
end
