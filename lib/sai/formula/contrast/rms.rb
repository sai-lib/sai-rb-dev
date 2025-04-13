# frozen_string_literal: true

module Sai
  module Formula
    module Contrast
      module RMS
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

            mean_luminance = (l1 + l2) / 2.0
            std_dev = Math.sqrt((((l1 - mean_luminance)**2) + ((l2 - mean_luminance)**2)) / 2.0)

            std_dev / mean_luminance
          end
        end
      end
    end
  end
end
