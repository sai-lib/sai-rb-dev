# frozen_string_literal: true

module Sai
  module Formula
    module Contrast
      module SAPC
        EXPONENT = 0.42
        SCALE_FACTOR = 1.14

        class << self
          include TypeFacade

          def calculate(color1, color2, **_options)
            [color1, color2].each do |color|
              next if color.is_a?(Space)

              raise TypeError, "color is invalid. Expected `Sai::Space`, got: #{color.inspect}"
            end

            Sai.cache.fetch(SAPC, :calculate, color1.identity, color2.identity) do
              l1 = color1.luminance
              l2 = color2.luminance

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
end
