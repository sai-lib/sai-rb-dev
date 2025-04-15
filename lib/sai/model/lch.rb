# frozen_string_literal: true

module Sai
  class Model
    class LCH < Model
      channel :lightness, :l, :percentage, display_precision: 2, differential_step: 0.2
      channel :chroma, :c, :linear, display_precision: 2, differential_step: 0.5
      channel :hue, :h, :hue_angle

      def to_css
        value_string = "#{lightness}% #{chroma.round(2)} #{hue.round(2)}"
        opacity_string = opacity < PERCENTAGE_RANGE.end ? " / #{(opacity / PERCENTAGE_RANGE.end)}" : ''
        "lch(#{value_string}#{opacity_string});"
      end

      def to_lab(**options)
        convert_to(Lab, **options) do
          nl, nc, nh = to_n_a

          h_rad = nh * Math::PI / 180.0

          a = nc * Math.cos(h_rad)
          b = nc * Math.sin(h_rad)

          [nl, a, b]
        end
      end

      def to_lch(**options)
        with_encoding_specification(**options)
      end

      def to_luv(**options)
        convert_to(Luv, **options) do
          nl, nc, nh = to_n_a

          h_degrees = nh * 360.0
          h_rad = h_degrees * (Math::PI / 180.0)

          u = nc * Math.cos(h_rad)
          v = nc * Math.sin(h_rad)

          [nl, u, v]
        end
      end

      def to_xyz(...)
        to_lab(...).to_xyz(...)
      end
    end
  end
end
