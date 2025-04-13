# frozen_string_literal: true

module Sai
  module Formula
    module Contrast
      module CIELab
        class << self
          def calculate(color1, color2, **options)
            [color1, color2].each do |color|
              next if color.is_a?(Model)

              raise TypeError, "color is invalid. Expected `Sai::Model`, got: #{color.inspect}"
            end

            color1 = color1.to_lab(**options)
            color2 = color2.to_lab(**options)

            l1 = color1.l
            l2 = color2.l

            l1, l2 = l2, l1 if l1 < l2
            l1 / l2
          end
        end
      end
    end
  end
end
