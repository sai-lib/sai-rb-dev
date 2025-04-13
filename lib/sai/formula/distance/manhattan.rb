# frozen_string_literal: true

module Sai
  module Formula
    module Distance
      module Manhattan
        DEFAULT_VISUAL_THRESHOLD = 7.0

        class << self
          def calculate(color1, color2, **options)
            [color1, color2].each do |color|
              next if color.is_a?(Model)

              raise TypeError, "color is invalid. Expected `Sai::Model`, got: #{color.inspect}"
            end

            r1, g1, b1 = color1.to_rgb(**options).to_n_a
            r2, g2, b2 = color2.to_rgb(**options).to_n_a

            (r2 - r1).abs + (g2 - g1).abs + (b2 - b1).abs
          end
        end
      end
    end
  end
end
