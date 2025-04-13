# frozen_string_literal: true

module Sai
  module Formula
    module Distance
      module DeltaE
        DEFAULT_VISUAL_THRESHOLD = 3.0

        class << self
          def calculate(color1, color2, **options)
            [color1, color2].each do |color|
              next if color.is_a?(Model)

              raise TypeError, "color is invalid. Expected `Sai::Model`, got: #{color.inspect}"
            end

            x1, y1, z1 = color1.to_xyz(**options).to_n_a
            x2, y2, z2 = color2.to_xyz(**options).to_n_a

            Math.sqrt(((x2 - x1)**2) + ((y2 - y1)**2) + ((z2 - z1)**2))
          end
        end
      end
    end
  end
end
