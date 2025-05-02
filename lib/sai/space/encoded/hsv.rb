# frozen_string_literal: true

module Sai
  module Space
    module Encoded
      class HSV < Base
        include RGB::Derivative

        implements Model::HSV

        def to_hsb(**options)
          convert_to_encoded(HSB, **options) { to_a }
        end

        def to_hsl(**options)
          convert_to_encoded(HSL, **options) do
            nh, ns, nv = to_a

            l = nv * (1.0 - (ns / 2.0))
            s_new = l.zero? || l == 1 ? 0.0 : (nv - l) / [l, 1.0 - l].min

            [nh, s_new, l]
          end
        end

        def to_hsv(...)
          convert_to_self(...)
        end

        def to_rgb(**options)
          convert_to_rgb(**options) do
            nh, ns, nv = to_a

            if ns.zero?
              [nv, nv, nv]
            else
              h_sector = (nh * 6.0)
              sector_index   = h_sector.to_i
              sector_decimal = h_sector - sector_index

              p = nv * (1.0 - ns)
              q = nv * (1.0 - (ns * sector_decimal))
              t = nv * (1.0 - (ns * (1.0 - sector_decimal)))

              case sector_index % 6.0
              when 0 then [nv, t, p]
              when 1 then [q, nv, p]
              when 2 then [p, nv, t]
              when 3 then [p, q, nv]
              when 4 then [t, p, nv]
              when 5 then [nv, p, q]
              end
            end
          end
        end
      end
    end
  end
end
