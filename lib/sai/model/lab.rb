# frozen_string_literal: true

module Sai
  class Model
    class Lab < Model
      DELTA = 6.0 / 29.0
      DELTA_SQUARED = DELTA * DELTA
      DELTA_CUBED = DELTA_SQUARED * DELTA

      channel :lightness, :l, :percentage, display_precision: 2, differential_step: 0.2
      channel :a, :a, :bipolar, display_precision: 2, differential_step: 0.2
      channel :b, :b, :bipolar, display_precision: 2, differential_step: 0.2

      cache_channels_with_high_precision

      def to_css
        value_string = "#{lightness.round}% #{a.round} #{b.round}"
        opacity_string = opacity < PERCENTAGE_RANGE.end ? " / #{(opacity / PERCENTAGE_RANGE.end)}" : ''
        "lab(#{value_string}#{opacity_string});"
      end

      def to_lab(**options)
        with_encoding_specification(**options)
      end

      def to_lch(**options)
        convert_to(LCH, **options) do
          nl, na, nb = to_n_a

          c = Math.sqrt((na * na) + (nb * nb))
          h = Math.atan2(nb, na) / Math::PI * 180.0
          h += 360.0 if h.negative?

          [nl, c, h]
        end
      end

      def to_xyz(**options)
        convert_to(XYZ, **options) do |encoding_specification|
          reference_white = encoding_specification.adapted_white_point

          p_max = PERCENTAGE_RANGE.end
          l_scaled = l * p_max

          fy = (l_scaled + 16.0) / 116.0
          fx = (a / 500.0) + fy
          fz = fy - (b / 200.0)

          x = fx > DELTA ? fx * fx * fx : 3.0 * DELTA_SQUARED * (fx - (4.0 / 29.0))
          y = l_scaled > (DELTA_CUBED * p_max) ? ((l_scaled + 16.0) / 116.0)**3 : l_scaled / (DELTA_CUBED * 100.0)
          z = fz > DELTA ? fz * fz * fz : 3.0 * DELTA_SQUARED * (fz - (4.0 / 29.0))

          [x, y, z].zip(reference_white.to_n_a).map { |rel, ref| rel * ref }
        end
      end
    end
  end
end
