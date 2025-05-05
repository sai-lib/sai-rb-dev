# frozen_string_literal: true

module Sai
  module Formula
    module Contrast
      module Weber
        class << self
          include TypeFacade

          def calculate(color1, color2, **_options)
            [color1, color2].each do |color|
              next if color.is_a?(Space)

              raise TypeError, "color is invalid. Expected `Sai::Space`, got: #{color.inspect}"
            end

            Sai.cache.fetch(Weber, :calculate, color1.identity, color2.identity) do
              l1 = color1.luminance
              l2 = color2.luminance

              (l1 - l2) / l2
            end
          end
        end
      end
    end
  end
end
