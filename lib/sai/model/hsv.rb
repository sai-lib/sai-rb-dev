# frozen_string_literal: true

module Sai
  class Model
    class HSV < Model
      FULL_SECTOR = 6.0

      channel :hue, :h, :hue_angle
      channel :saturation, :s, :percentage
      channel :value, :v, :percentage
      alias b v
      alias brightness value
      alias contract_brightness with_value_contracted_by
      alias decrement_brightness with_value_decremented_by
      alias increment_brightness with_value_incremented_by
      alias scale_brightness with_value_scaled_by
      alias with_brightness_contracted_by with_value_contracted_by
      alias with_brightness_decremented_by with_value_decremented_by
      alias with_brightness_incremented_by with_value_incremented_by
      alias with_brightness_scaled_by with_value_scaled_by

      def to_hsl(**options)
        convert_to(HSL, **options) do
          nh, ns, nv = to_n_a

          l = nv * (1.0 - (ns / 2.0))
          s_new = l.zero? || l == 1 ? 0.0 : (nv - l) / [l, 1.0 - l].min

          [nh, s_new, l]
        end
      end

      def to_hsv(**options)
        with_encoding_specification(**options)
      end
      alias to_hsb to_hsv

      def to_rgb(**options)
        convert_to(RGB, **options) do
          nh, ns, nv = to_n_a

          if ns == 0.0
            [nv, nv, nv]
          else
            h_sector = (nh * FULL_SECTOR)
            sector_index = h_sector.to_i
            sector_decimal = h_sector - sector_index

            p = nv * (1.0 - ns)
            q = nv * (1.0 - (ns * sector_decimal))
            t = nv * (1.0 - (ns * (1.0 - sector_decimal)))

            case sector_index % FULL_SECTOR
            when 0
              [nv, t, p]
            when 1
              [q, nv, p]
            when 2
              [p, nv, t]
            when 3
              [p, q, nv]
            when 4
              [t, p, nv]
            when 5
              [nv, p, q]
            end
          end
        end
      end

      def to_xyz(...)
        to_rgb(...).to_xyz(...)
      end
    end

    HSB = HSV
  end
end
