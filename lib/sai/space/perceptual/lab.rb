# frozen_string_literal: true

module Sai
  module Space
    module Perceptual
      class Lab < Base
        autoload :D50, 'sai/space/perceptual/lab/d50'
        autoload :D65, 'sai/space/perceptual/lab/d65'

        DELTA = 6.0 / 29.0
        DELTA_SQUARED = DELTA * DELTA
        DELTA_CUBED = DELTA_SQUARED * DELTA

        abstract_space
        implements Model::LAB

        def to_lch(**options)
          space = case __callee__
                  when :to_lch_d65 then LCh::D65
                  else LCh::D50
                  end

          convert_to(space, **options) do |context|
            nl, na, nb = with_context(**context.to_h).to_a

            c = Math.sqrt((na * na) + (nb * nb))
            h = (Math.atan2(nb, na) / Math::PI * 180.0) / 360.0
            h += 1.0 if h.negative?

            [nl, c, h]
          end
        end
        alias to_lch_d50 to_lch
        alias to_lch_d65 to_lch

        def to_xyz(**options)
          convert_to(Physiological::XYZ, **options) do |context|
            nl, = to_a

            p_max = PERCENTAGE_RANGE.max
            sl    = nl * p_max

            fy = (sl + 16.0) / 116.0
            fx = (a / 500.0) + fy
            fz = fy - (b / 200.0)

            x = fx > DELTA ? fx * fx * fx : 3.0 * DELTA_SQUARED * (fx - (4.0 / 29.0))
            y = sl > (DELTA_CUBED * p_max) ? ((sl + 16.0) / 116.0)**3 : sl / (DELTA_CUBED * 100.0)
            z = fz > DELTA ? fz * fz * fz : 3.0 * DELTA_SQUARED * (fz - (4.0 / 29.0))

            [x, y, z].zip(context.white_point.to_a).map { |rel, ref| rel * ref }
          end
        end
      end
    end
  end
end
