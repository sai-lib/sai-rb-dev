# frozen_string_literal: true

module Sai
  module Formula
    module Contrast
      module CIELab
        class << self
          include TypeFacade

          def calculate(color1, color2, **options)
            [color1, color2].each do |color|
              next if color.is_a?(Space)

              raise TypeError, "color is invalid. Expected `Sai::Space`, got: #{color.inspect}"
            end

            color1 = color1.to_lab(**options)
            color2 = color2.to_lab(**options)

            Sai.cache.fetch(CIELab, :calculate, color1.identity, color2.identity) do
              l1 = color1.l.normalized
              l2 = color2.l.normalized

              l1, l2 = l2, l1 if l1 < l2
              l1 / l2
            end
          end
        end
      end
    end
  end
end
