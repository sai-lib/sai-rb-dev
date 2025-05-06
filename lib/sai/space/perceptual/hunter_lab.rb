# frozen_string_literal: true

module Sai
  module Space
    module Perceptual
      class HunterLab < Base
        implements Model::LAB

        def to_xyz(**options)
          convert_to(Physiological::XYZ, **options) do |context|
            nl, na, nb = to_a
            rnx, rny, rnz = context.white_point.to_a

            ka = (175 / 198.04) * (rnx + rny)
            kb = (70.0 / 218.11) * (rny + rnz)

            y = rny * (nl**2)
            p = ((na / 100.0) / ka) * Math.sqrt(y / rny)
            q = ((nb / 100.0) / kb) * Math.sqrt(y / rny)

            x = rnx * (p + (y / rny))
            z = rnz * ((y / rny) - q)
            [x, y, z]
          end
        end
      end
    end
  end
end
