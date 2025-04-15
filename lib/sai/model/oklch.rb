# frozen_string_literal: true

module Sai
  class Model
    class Oklch < Model
      channel :lightness, :l, :percentage, display_precision: 2, differential_step: 0.2
      channel :chroma, :c, :linear, display_precision: 2, differential_step: 0.5
      channel :hue, :h, :hue_angle

      def to_css
        value_string = "#{lightness.round}% #{chroma.round(2)} #{hue.round}"
        opacity_string = opacity < PERCENTAGE_RANGE.end ? " / #{(opacity / PERCENTAGE_RANGE.end)}" : ''
        "oklch(#{value_string}#{opacity_string});"
      end

      def to_oklab(**options)
        convert_to(Oklab, **options) do
          nl, nc, nh = to_n_a
          h_rad = nh * 2 * Math::PI

          a = nc * Math.cos(h_rad)
          b = nc * Math.sin(h_rad)

          [nl, a, b]
        end
      end

      def to_oklch(**options)
        with_encoding_specification(**options)
      end

      def to_xyz(...)
        to_oklab(...).to_xyz(...)
      end
    end
  end
end
