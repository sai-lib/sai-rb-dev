# frozen_string_literal: true

module Sai
  module Space
    module Perceptual
      class LCh < Base
        autoload :D50, 'sai/space/perceptual/l_ch/d50'
        autoload :D65, 'sai/space/perceptual/l_ch/d65'

        abstract_space
        implements Model::LCH

        def to_lab_d50(**options)
          convert_to(Lab::D50, **options) do |context|
            nl, nc, nh = with_context(**context.to_h).to_a

            h_rad = nh * Math::PI / 180.0

            a = nc * Math.cos(h_rad)
            b = nc * Math.sin(h_rad)

            [nl, a, b]
          end
        end
        alias to_lab to_lab_d50

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

        def to_xyz(...)
          to_lab_d50(...).to_xyz(...)
        end
      end
    end
  end
end
