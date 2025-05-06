# frozen_string_literal: true

module Sai
  module Space
    module Perceptual
      class LCh < Base
        autoload :D50, 'sai/space/perceptual/l_ch/d50'
        autoload :D65, 'sai/space/perceptual/l_ch/d65'

        abstract_space
        implements Model::LCH

        def to_lab(**options)
          space = case __callee__
                  when :to_lab_d65 then Lab::D65
                  else Lab::D50
                  end

          convert_to(space, **options) do |context|
            nl, nc, nh = with_context(**context.to_h).to_a

            h_rad = nh * 2 * Math::PI

            a = nc * Math.cos(h_rad)
            b = nc * Math.sin(h_rad)

            [nl, a, b]
          end
        end
        alias to_lab_d50 to_lab
        alias to_lab_d65 to_lab

        def to_luv(**options)
          convert_to(Luv, **options) do |context|
            nl, nc, nh = with_context(**context.to_h).to_a

            h_degrees = nh * 360.0
            h_rad = h_degrees * (Math::PI / 180.0)

            u = nc * Math.cos(h_rad)
            v = nc * Math.sin(h_rad)

            [nl, u, v]
          end
        end

        def to_xyz(**options)
          convert_to(Physiological::XYZ, **options) do |context|
            nl, nc, nh = to_a

            h_rad = nh * 2 * Math::PI

            a = nc * Math.cos(h_rad)
            b = nc * Math.sin(h_rad)

            p_max = PERCENTAGE_RANGE.max
            sl    = nl * p_max

            fy = (sl + 16.0) / 116.0
            fx = (a / 500.0) + fy
            fz = fy - (b / 200.0)

            x = fx > Lab::DELTA ? fx * fx * fx : 3.0 * Lab::DELTA_SQUARED * (fx - (4.0 / 29.0))
            y = sl > (Lab::DELTA_CUBED * p_max) ? ((sl + 16.0) / 116.0)**3 : sl / (Lab::DELTA_CUBED * 100.0)
            z = fz > Lab::DELTA ? fz * fz * fz : 3.0 * Lab::DELTA_SQUARED * (fz - (4.0 / 29.0))

            [x, y, z].zip(context.white_point.to_a).map { |rel, ref| rel * ref }
          end
        end
      end
    end
  end
end
