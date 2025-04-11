# frozen_string_literal: true

module Sai
  class Model
    class Luv < Model
      channel :lightness, :l, :percentage, display_precision: 2, differential_step: 0.2
      channel :u, :u, :bipolar, display_precision: 2, differential_step: 0.2
      channel :v, :v, :bipolar, display_precision: 2, differential_step: 0.2

      def to_lch(**options)
        convert_to(LCH, **options) do
          nl, nu, nv = to_n_a

          c = Math.sqrt((nu * nu) + (nv * nv))
          h = Math.atan2(nv, nu) * (180.0 / Math::PI)
          h += 360.0 if h.negative?

          [nl, c, h / 360.0]
        end
      end

      def to_luv(**options)
        with_encoding_specification(**options)
      end

      def to_xyz(**options)
        convert_to(XYZ, **options) do |encoding_specification|
          nl, nu, nv = to_n_a
          white_point = encoding_specification.adapted_white_point

          xn, yn, zn = white_point.to_n_a

          l = nl * 100.0
          u = (nu * 200.0) - 100.0
          v = (nv * 200.0) - 100.0

          return [0.0, 0.0, 0.0] if l <= 0.0

          un_prime = 4.0 * xn / (xn + (15.0 * yn) + (3.0 * zn))
          vn_prime = 9.0 * yn / (xn + (15.0 * yn) + (3.0 * zn))

          u_prime = (u / (13.0 * l)) + un_prime
          v_prime = (v / (13.0 * l)) + vn_prime

          y = if l > 8.0
                yn * (((l + 16.0) / 116.0)**3)
              else
                yn * l / 903.3
              end

          x = y * 9.0 * u_prime / (4.0 * v_prime)
          z = y * (12.0 - (3.0 * u_prime) - (20.0 * v_prime)) / (4.0 * v_prime)

          [x, y, z]
        end
      end
    end
  end
end
