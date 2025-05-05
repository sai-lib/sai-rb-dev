# frozen_string_literal: true

module Sai
  module Formula
    module Distance
      module Euclidean
        DEFAULT_VISUAL_THRESHOLD = 5.0

        class << self
          include TypeFacade

          def calculate(color1, color2, **options)
            [color1, color2].each do |color|
              next if color.is_a?(Space)

              raise TypeError, "color is invalid. Expected `Sai::Space`, got: #{color.inspect}"
            end

            r1, g1, b1 = color1.to_rgb(**options).to_a
            r2, g2, b2 = color2.to_rgb(**options).to_a

            Sai.cache.fetch(Euclidean, :calculate, r1, g1, b1, r2, g2, b2) do
              Math.sqrt(((r2 - r1)**2) + ((g2 - g1)**2) + ((b2 - b1)**2))
            end
          end
        end
      end
    end
  end
end
