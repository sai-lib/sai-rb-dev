# frozen_string_literal: true

module Sai
  module Space
    module Encoded
      class Okhsl < Base
        include RGB::Derivative

        implements Model::HSL
        with_native illuminant: Illuminant::D65, rgb_space: RGB::Standard

        def to_okhsl(...)
          convert_to_self(...)
        end

        def to_oklab(**options)
          convert_to(Perceptual::Oklab, **options) do
            h, s, l = to_a

            cusp = Support::OkMath.find_cusp(h)
            max_c = Support::OkMath.max_chroma_for_lightness(cusp, l)
            c = s * max_c

            a = c * Math.cos(2 * Math::PI * h)
            b = c * Math.sin(2 * Math::PI * h)

            [l, a, b]
          end
        end

        def to_xyz(...)
          to_oklab(...).to_xyz(...)
        end
      end
    end
  end
end
