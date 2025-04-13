# frozen_string_literal: true

module Sai
  module Formula
    module Contrast
      module MBS
        B_COEFFICIENT = 0.114
        G_COEFFICIENT = 0.587
        R_COEFFICIENT = 0.299
        RECOMMENDED_MINIMUM = 125

        class << self
          def calculate(color1, color2, **options)
            [color1, color2].each do |color|
              next if color.is_a?(Model)

              raise TypeError, "color is invalid. Expected `Sai::Model`, got: #{color.inspect}"
            end

            color1 = color1.to_rgb(**options)
            color2 = color2.to_rgb(**options)

            (calculate_brightness(color1) - calculate_brightness(color2)).abs
          end

          private

          def calculate_brightness(rgb)
            (R_COEFFICIENT * rgb.red) + (G_COEFFICIENT * rgb.green) + (B_COEFFICIENT * rgb.blue)
          end
        end
      end
    end
  end
end
