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
          def calculate(color1, color2, **options)
            [color1, color2].each do |color|
              next if color.is_a?(Model)

              raise TypeError, "color is invalid. Expected `Sai::Model`, got: #{color.inspect}"
            end

            l1, l2 = [
              color1.to_xyz(**options).y.normalized,
              color2.to_xyz(**options).y.normalized,
            ].freeze

            offset = options.fetch(:offset, DEFAULT_OFFSET)

            l1, l2 = l2, l1 if l1 < l2

            (l1 + offset) / (l2 + offset)
          end
        end
      end
    end
  end
end
