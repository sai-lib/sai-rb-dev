# frozen_string_literal: true

module Sai
  module Formula
    module Contrast
      module RMS
        class << self
          include TypeFacade

          def calculate(color1, color2, **_options)
            [color1, color2].each do |color|
              next if color.is_a?(Space)

              raise TypeError, "color is invalid. Expected `Sai::Space`, got: #{color.inspect}"
            end

            Sai.cache.fetch(RMS, :calculate, color1.identity, color2.identity) do
              l1 = color1.luminance
              l2 = color2.luminance

              mean_luminance = (l1 + l2) / 2.0
              std_dev = Math.sqrt((((l1 - mean_luminance)**2) + ((l2 - mean_luminance)**2)) / 2.0)

              std_dev / mean_luminance
            end
          end
        end
      end
    end
  end
end
