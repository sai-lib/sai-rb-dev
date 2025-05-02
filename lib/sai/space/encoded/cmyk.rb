# frozen_string_literal: true

module Sai
  module Space
    module Encoded
      class CMYK < Base
        include RGB::Derivative

        implements Model::CMYK

        def to_cmy(**options)
          convert_to_encoded(CMY, **options) do
            nc, nm, ny, nk = to_a
            [
              (nc * (1.0 - nk)) + nk,
              (nm * (1.0 - nk)) + nk,
              (ny * (1.0 - nk)) + nk,
            ]
          end
        end

        def to_cmyk(...)
          convert_to_self(...)
        end

        def to_rgb(**options)
          convert_to_rgb(**options) do
            nc, nm, ny, nk = to_a
            [
              (1.0 - nc) * (1.0 - nk),
              (1.0 - nm) * (1.0 - nk),
              (1.0 - ny) * (1.0 - nk),
            ]
          end
        end
      end
    end
  end
end
