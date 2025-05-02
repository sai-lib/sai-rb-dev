# frozen_string_literal: true

module Sai
  module Space
    module Perceptual
      class Lab
        class D50 < Lab
          with_native illuminant: Illuminant::D50
          identified_as :lab_d50

          def to_css
            opacity_string = opacity < PERCENTAGE_RANGE.end ? " / #{opacity.round(2)}" : ''
            "lab(#{lightness} #{a} #{b}#{opacity_string})"
          end

          def to_lab_d50(...)
            convert_to_self(...)
          end
          alias to_lab to_lab_d50
        end
      end
    end
  end
end
