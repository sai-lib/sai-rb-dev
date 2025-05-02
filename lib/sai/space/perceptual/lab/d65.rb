# frozen_string_literal: true

module Sai
  module Space
    module Perceptual
      class Lab
        class D65 < Lab
          with_native illuminant: Illuminant::D65
          identified_as :lab_d65

          def to_css
            to_lab_d50.to_css
          end

          def to_lab_d65(...)
            convert_to_self(...)
          end
        end
      end
    end
  end
end
