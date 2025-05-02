# frozen_string_literal: true

module Sai
  module Space
    module Perceptual
      class LCh
        class D65 < LCh
          with_native illuminant: Illuminant::D65
          identified_as :lch_d65

          def to_css
            to_lch_d50.to_css
          end

          def to_lch_d65(...)
            convert_to_self(...)
          end
        end
      end
    end
  end
end
