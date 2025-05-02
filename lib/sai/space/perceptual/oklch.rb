# frozen_string_literal: true

module Sai
  module Space
    module Perceptual
      class Oklch < Base
        implements Model::LCH
        with_native illuminant: Illuminant::D65

        def to_css
          opacity_string = opacity < PERCENTAGE_RANGE.end ? " / #{opacity.round(2)}" : ''
          "oklch(#{lightness} #{chroma} #{hue}#{opacity_string})"
        end

        def to_okhsl(**options)
          convert_to(Okhsl, **options) do |context|
            nl, nc, nh = with_context(**context.to_h).to_a

            if nl <= 0.0
              [0.0, 0.0, 0.0]
            elsif nl >= 1.0
              [0.0, 0.0, 1.0]
            else
              h = nh

              s = 0.0
              if nl > 0.0 && nl < 1.0
                toe = 0.2
                k = if nl < toe
                      0.8 * (nl / toe)
                    elsif nl > (1.0 - toe)
                      0.8 * ((1.0 - nl) / toe)
                    else
                      0.8
                    end

                s = nc / k if k > 0.0
                s = [s, 1.0].min
              end

              [h, s, nl]
            end
          end
        end

        def to_okhsv(**options)
          convert_to(Okhsv, **options) do |context|
            nl, nc, nh = with_context(**context.to_h).to_a

            if nl <= 0.0
              [0.0, 0.0, 0.0]
            else
              h = nh

              v = nl / (1.0 - (0.4 * nc))
              v = [v, 1.0].min

              s = 0.0
              s = nc / v if v > 0.0

              [h, s.clamp(FRACTION_RANGE), v]
            end
          end
        end

        def to_oklab(**options)
          convert_to(Oklab, **options) do |context|
            nl, nc, nh = with_context(**context.to_h).to_a
            h_rad = nh * 2 * Math::PI

            a = nc * Math.cos(h_rad)
            b = nc * Math.sin(h_rad)

            [nl, a, b]
          end
        end

        def to_oklch(...)
          convert_to_self(...)
        end

        def to_xyz(...)
          to_oklab(...).to_xyz(...)
        end
      end
    end
  end
end
