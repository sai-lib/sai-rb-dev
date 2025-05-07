# frozen_string_literal: true

module Sai
  module Space
    module Perceptual
      class Luv < Base
        implements Model::LUV
        with_native illuminant: Illuminant::D65

        def to_lch_d65(**options)
          convert_to(LCh::D65, **options) do
            nl, nu, nv = to_a

            c = Math.sqrt((nu * nu) + (nv * nv))
            h = Math.atan2(nv, nu) * (180.0 / Math::PI)
            h += 360.0 if h.negative?

            [nl, c, h / 360.0]
          end
        end

        def to_luv(...)
          convert_to_self(...)
        end

        def to_xyz(**options)
          convert_to(Physiological::XYZ, **options) do |context|
            nl, nu, nv = with_context(**context.to_h).to_a
            xn, yn, zn = context.white_point.to_a

            ll = nl * 100.0
            lu = (nu * 200.0) - 100.0
            lv = (nv * 200.0) - 100.0

            if ll <= 0.0
              [0.0, 0.0, 0.0]
            else
              nup = 4.0 * xn / (xn + (15.0 * yn) + (3.0 * zn))
              nvp = 9.0 * yn / (xn + (15.0 * yn) + (3.0 * zn))

              up = (lu / (13.0 * ll)) + nup
              vp = (lv / (13.0 * ll)) + nvp

              y = if ll > 8.0
                    yn * (((ll + 16.0) / 116.0)**3)
                  else
                    yn * ll / 903.3
                  end

              x = y * 9.0 * up / (4.0 * vp)
              z = y * (12.0 - (3.0 * up) - (20.0 * vp)) / (4.0 * vp)

              [x, y, z]
            end
          end
        end
      end
    end
  end
end
