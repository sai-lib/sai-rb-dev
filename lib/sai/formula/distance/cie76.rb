# frozen_string_literal: true

module Sai
  module Formula
    module Distance
      module CIE76
        DEFAULT_VISUAL_THRESHOLD = 2.3

        class << self
          def calculate(color1, color2, **options)
            [color1, color2].each do |color|
              next if color.is_a?(Model)

              raise TypeError, "color is invalid. Expected `Sai::Model`, got: #{color.inspect}"
            end

            color1 = color1.to_lab(**options)
            color2 = color2.to_lab(**options)

            p_max = PERCENTAGE_RANGE.end
            l1, a1, b1 = color1.to_n_a.map { |channel| channel * p_max }
            l2, a2, b2 = color2.to_n_a.map { |channel| channel * p_max }

            Math.sqrt(((l2 - l1)**2) + ((a2 - a1)**2) + ((b2 - b1)**2))
          end
        end
      end
    end
  end
end
