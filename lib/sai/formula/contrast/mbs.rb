# frozen_string_literal: true

module Sai
  module Formula
    module Contrast
      module MBS
        RECOMMENDED_MINIMUM = 125

        class << self
          include TypeFacade

          def calculate(color1, color2, **options)
            [color1, color2].each do |color|
              next if color.is_a?(Space)

              raise TypeError, "color is invalid. Expected `Sai::Space`, got: #{color.inspect}"
            end

            color1 = color1.to_rgb(**options)
            color2 = color2.to_rgb(**options)

            Sai.cache.fetch(MBS, :calculate, color1.identity, color2.identity) do
              (calculate_brightness(color1) - calculate_brightness(color2)).abs
            end
          end

          private

          def calculate_brightness(rgb)
            (Standard::BT601::RED_COEFFICIENT * rgb.red) +
              (Standard::BT601::GREEN_COEFFICIENT * rgb.green) +
              (Standard::BT601::BLUE_COEFFICIENT * rgb.blue)
          end
        end
      end
    end
  end
end
