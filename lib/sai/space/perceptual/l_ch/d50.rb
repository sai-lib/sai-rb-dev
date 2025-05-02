# frozen_string_literal: true

module Sai
  module Space
    module Perceptual
      class LCh
        class D50 < LCh
          with_native illuminant: Illuminant::D50
          identified_as :lch_d50

          def to_css
            opacity_string = opacity < PERCENTAGE_RANGE.end ? " / #{opacity.round(2)}" : ''
            "lch(#{lightness} #{chroma} #{hue}#{opacity_string})"
          end

          def to_lch_d50(...)
            convert_to_self(...)
          end
          alias to_lch to_lch_d50
        end
      end
    end
  end
end
