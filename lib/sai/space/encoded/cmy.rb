# frozen_string_literal: true

module Sai
  module Space
    module Encoded
      class CMY < Base
        include RGB::Derivative

        implements Model::CMY

        def to_cmy(...)
          convert_to_self(...)
        end

        def to_cmyk(**options)
          convert_to_encoded(CMYK, **options) do
            nc, nm, ny = to_a
            k = [nc, nm, ny].min

            if k == 1
              [0, 0, 0, k]
            else
              [
                (c - k) / (1.0 - k),
                (m - k) / (1.0 - k),
                (y - k) / (1.0 - k),
                k,
              ]
            end
          end
        end

        def to_rgb(**options)
          convert_to_rgb(**options) do
            nc, nm, ny = to_a
            [
              1.0 - nc,
              1.0 - nm,
              1.0 - ny,
            ]
          end
        end
      end
    end
  end
end
