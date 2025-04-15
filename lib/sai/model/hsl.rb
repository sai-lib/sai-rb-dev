# frozen_string_literal: true

module Sai
  class Model
    class HSL < Model
      FULL_SECTOR = 6.0

      channel :hue, :h, :hue_angle
      channel :saturation, :s, :percentage
      channel :lightness, :l, :percentage

      def to_css
        value_string = "#{hue} #{saturation}% #{lightness}%"
        opacity_string = opacity < PERCENTAGE_RANGE.end ? " / #{(opacity / PERCENTAGE_RANGE.end)}" : ''
        "hsl(#{value_string}#{opacity_string});"
      end

      def to_hsl(**options)
        with_encoding_specification(**options)
      end

      def to_hsv(**options)
        convert_to(HSV, **options) do
          nh, ns, nl = to_n_a

          v = nl + (ns * [nl, 1.0 - nl].min)
          s_new = v.zero? ? 0.0 : 2.0 * (1.0 - (nl / v))

          [nh, s_new, v]
        end
      end
      alias to_hsb to_hsv

      def to_rgb(**options)
        convert_to(RGB, **options) do
          nh, ns, nl = to_n_a

          if ns <= 0.0
            [nl, nl, nl]
          elsif nl <= 0.0
            [0.0, 0.0, 0.0]
          elsif nl >= 1.0
            [1.0, 1.0, 1.0]
          else
            c = (1.0 - ((2.0 * nl) - 1.0).abs) * ns
            x = c * (1.0 - (((nh * FULL_SECTOR) % (FULL_SECTOR / 3.0)) - 1.0).abs)
            m = nl - (c / 2.0)

            segment = (nh * FULL_SECTOR).floor
            r1, g1, b1 = case segment % FULL_SECTOR
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

      def to_xyz(...)
        to_rgb(...).to_xyz(...)
      end
    end
  end
end
