# frozen_string_literal: true

module Sai
  module Formula
    module Contrast
      module Michelson
        class << self
          include TypeFacade

          def calculate(color1, color2, **_options)
            [color1, color2].each do |color|
              next if color.is_a?(Space)

              raise TypeError, "color is invalid. Expected `Sai::Space`, got: #{color.inspect}"
            end

            Sai.cache.fetch(Michelson, :calculate, color1.identity, color2.identity) do
              luminance = [color1.luminance, color2.luminance]
              l_max = luminance.max
              l_min = luminance.min

              (l_max - l_min) / (l_max + l_min)
            end
          end
        end
      end
    end
  end
end
