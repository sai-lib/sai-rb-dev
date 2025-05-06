# frozen_string_literal: true

module Sai
  module Space
    module Perceptual
      class Oklab < Base
        LINEAR_LMS_MATRIX = Sai::Core::Matrix[
          [0.2104542553, 0.7936177850, -0.0040720468],
          [1.9779984951, -2.4285922050, 0.4505937099],
          [0.0259040371, 0.7827717662, -0.8086757660],
        ]

        LINEAR_RGB_MATRIX = Sai::Core::Matrix[
          [0.4122214708, 0.5363325363, 0.0514459929],
          [0.2119034982, 0.6806995451, 0.1073969566],
          [0.0883024619, 0.2817188376, 0.6299787005],
        ]

        LINEAR_XYZ_MATRIX = Sai::Core::Matrix[
          [0.8189330101, 0.3618667424, -0.1288597137],
          [0.0329845436, 0.9293118715, 0.0361456387],
          [0.0482003018, 0.2643662691, 0.6338517070],
        ].freeze

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

        def to_rgb(**options)
          rgb_space = options.fetch(:rgb_space, Sai.config.default_rgb_space)

          convert_to(rgb_space, map_to_gamut: true, **options) do
            nl, na, nb = to_a

            ll = nl + (0.3963377774 * na) + (0.2158037573 * nb)
            lm = nl - (0.1055613458 * na) - (0.0638541728 * nb)
            ls = nl - (0.0894841775 * na) - (1.2914855480 * nb)

            linear_lms = [ll, lm, ls].map { |component| component**3 }

            rgb_matrix = LINEAR_RGB_MATRIX.inverse
            linear_rgb = (rgb_matrix * Sai::Core::Matrix.column_vector(linear_lms)).to_a.flatten

            srgb_values = linear_rgb.map { |component| Encoded::RGB::Standard.from_linear(component) }

            Encoded::RGB::Standard.from_intermediate(*srgb_values).to_rgb(rgb_space:).to_a
          end
        end

        def to_xyz(**options)
          convert_to(Physiological::XYZ, **options) do |context|
            lab = with_context(**context.to_h).to_a

            lms_matrix = LINEAR_LMS_MATRIX.inverse
            xyz_matrix = LINEAR_XYZ_MATRIX.inverse

            lms = (lms_matrix * lms_matrix.column_vector(lab)).to_a.flatten
            linear = lms.map { |component| component**3 }

            (xyz_matrix * xyz_matrix.column_vector(linear)).to_a.flatten
          end
        end
      end
    end
  end
end
