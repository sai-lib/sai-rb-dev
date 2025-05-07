# frozen_string_literal: true

module Sai
  module Space
    module Encoded
      class HWB < Base
        include RGB::Derivative

        implements Model::HWB

        def to_hsb(**options)
          convert_to_encoded(HSB, **options) { to_hsv(**options).to_a }
        end

        def to_hsl(**options)
          convert_to_encoded(HSL, **options) do
            nh, nw, nb = to_a

            if nw + nb >= 1
              s = 0.0
              v = w / (w + b)
            else
              v = 1.0 - nb
              s = 1.0 - (nw / v)
            end

            l  = v * (1.0 - (s / 2.0))
            sl = l.zero? || l == 1 ? 0.0 : (v - l) / [l, 1.0 - l].min

            [nh, sl, l]
          end
        end

        def to_hsv(**options)
          convert_to_encoded(HSV, **options) do
            nh, nw, nb = to_a

            if nw + nb >= 1
              [nh, 0.0, nw / (nw + nb)]
            else
              v = 1 - nb
              s = 1 - (nw / v)
              [nh, s, v]
            end
          end
        end

        def to_hwb(...)
          convert_to_self(...)
        end

        def to_rgb(**options)
          convert_to_rgb(**options) do
            nh, nw, nb = to_a

            if nw + nb > 1
              scale = nw + nb
              nw /= scale
              nb /= scale
            end

            hue_portion = 1 - nw - nb

            i = (nh / 60.0).floor
            f = (nh / 60.0) - i
            p = 0
            q = 1 - f
            t = f

            rr, rg, rb = case i % 6
                         when 0 then [1, t, p]
                         when 1 then [q, 1, p]
                         when 2 then [p, 1, t]
                         when 3 then [p, q, 1]
                         when 4 then [t, p, 1]
                         when 5 then [1, p, q]
                         end

            [
              ((rr * hue_portion) + nw),
              ((rg * hue_portion) + nw),
              ((rb * hue_portion) + nw),
            ]
          end
        end
      end
    end
  end
end
