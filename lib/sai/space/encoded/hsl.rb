# frozen_string_literal: true

module Sai
  module Space
    module Encoded
      class HSL < Base
        include RGB::Derivative

        implements Model::HSL

        def to_css
          opacity_string = opacity < PERCENTAGE_RANGE.end ? " / #{opacity.round(2)}" : ''
          "hsl(#{hue} #{saturation} #{lightness}#{opacity_string})"
        end

        def to_hsb(**options)
          convert_to_encoded(HSB, **options) { to_hsv(**options).to_a }
        end

        def to_hsl(...)
          convert_to_self(...)
        end

        def to_hsv(**options)
          convert_to_encoded(HSV, **options) do
            nh, ns, nl = to_a

            v = nl + (ns * [nl, 1.0 - nl].min)
            s_new = v.zero? ? 0.0 : 2.0 * (1.0 - (nl / v))

            [nh, s_new, v]
          end
        end

        def to_hwb(**options)
          convert_to_encoded(HWB, **options) do
            nh, ns, nl = to_a

            v = if nl <= 0.5
                  nl * (1.0 + ns)
                else
                  (nl + ns) - (nl * ns)
                end

            if v.zero?
              [nh, 0.0, 1.0]
            else
              sv = 2 * (v - nl) / v
              w = v * (1.0 - sv)
              b = 1.0 - v
              [nh, w, b]
            end
          end
        end

        def to_rgb(**options)
          convert_to_rgb(**options) do
            nh, ns, nl = to_a

            if ns <= 0
              [nl, nl, nl]
            elsif nl <= 0
              [0.0, 0.0, 0.0]
            elsif nl >= 1.0
              [1.0, 1.0, 1.0]
            else
              c = (1.0 - ((2.0 * nl) - 1.0).abs) * ns
              x = c * (1.0 - (((nh * 6.0) % (6.0 / 3.0)) - 1.0).abs)
              m = nl - (c / 2.0)

              segment = (nh * 6.0).floor
              r1, g1, b1 = case segment % 6.0
                           when 0 then [c, x, 0.0]
                           when 1 then [x, c, 0.0]
                           when 2 then [0.0, c, x]
                           when 3 then [0.0, x, c]
                           when 4 then [x, 0.0, c]
                           when 5 then [c, 0.0, x]
                           end

              [r1 + m, g1 + m, b1 + m]
            end
          end
        end
      end
    end
  end
end
