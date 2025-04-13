# frozen_string_literal: true

module Sai
  module Formula
    module Contrast
      module Michelson
        class << self
          def calculate(color1, color2, **options)
            [color1, color2].each do |color|
              next if color.is_a?(Model)

              raise TypeError, "color is invalid. Expected `Sai::Model`, got: #{color.inspect}"
            end

            luminance = [
              color1.to_xyz(**options).y.normalized,
              color2.to_xyz(**options).y.normalized,
            ].freeze

            l_max = luminance.max
            l_min = luminance.min

            (l_max - l_min) / (l_max + l_min)
          end
        end
      end
    end
  end
end
