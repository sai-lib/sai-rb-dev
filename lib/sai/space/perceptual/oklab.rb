# frozen_string_literal: true

module Sai
  module Space
    module Perceptual
      class Oklab < Base
        M1 = Sai::Core::Matrix[
          [0.8189330101, 0.3618667424, -0.1288597137],
          [0.0329845436, 0.9293118715, 0.0361456387],
          [0.0482003018, 0.2643662691, 0.6338517070],
        ].freeze

        M2 = Sai::Core::Matrix[
          [0.2104542553, 0.7936177850, -0.0040720468],
          [1.9779984951, -2.4285922050, 0.4505937099],
          [0.0259040371, 0.7827717662, -0.8086757660],
        ]

        implements Model::LAB
        with_native illuminant: Illuminant::D65

        def to_css
          opacity_string = opacity < PERCENTAGE_RANGE.end ? " / #{opacity.round(2)}" : ''
          "oklab(#{lightness} #{a} #{b}#{opacity_string})"
        end

        def to_oklab(...)
          convert_to_self(...)
        end

        def to_oklch(**options)
          convert_to(Oklch, **options) do |context|
            nl, na, nb = with_context(**context.to_h).to_a

            c = Math.sqrt((na * na) + (nb * nb))
            h = (Math.atan2(nb, na) / Math::PI * 180.0) / 360.0
            h += 1.0 if h.negative?

            [nl, c, h]
          end
        end

        def to_xyz(**options)
          convert_to(Physiological::XYZ, **options) do |context|
            lab = with_context(**context.to_h).to_a

            lms_matrix = M2.inverse
            xyz_matrix = M1.inverse

            lms = (lms_matrix * lms_matrix.column_vector(lab)).to_a.flatten
            linear = lms.map { |component| component**3 }

            (xyz_matrix * xyz_matrix.column_vector(linear)).to_a.flatten
          end
        end
      end
    end
  end
end
