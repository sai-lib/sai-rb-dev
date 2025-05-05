# frozen_string_literal: true

module Sai
  module Formula
    module Contrast
      module WCAG
        DEFAULT_AA_LARGE_THRESHOLD = 3.0
        DEFAULT_AA_THRESHOLD = 4.5
        DEFAULT_AAA_LARGE_THRESHOLD = 4.5
        DEFAULT_AAA_THRESHOLD = 7.0
        DEFAULT_OFFSET = 0.05

        class << self
          include TypeFacade

          def calculate(color1, color2, **options)
            [color1, color2].each do |color|
              next if color.is_a?(Space)

              raise TypeError, "color is invalid. Expected `Sai::Space`, got: #{color.inspect}"
            end

            Sai.cache.fetch(WCAG, :calculate, color1.identity, color2.identity) do
              l1 = color1.luminance
              l2 = color2.luminance

              offset = options.fetch(:offset, DEFAULT_OFFSET)

              l1, l2 = l2, l1 if l1 < l2

              (l1 + offset) / (l2 + offset)
            end
          end
        end
      end
    end
  end
end
