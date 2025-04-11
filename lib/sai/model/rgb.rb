# frozen_string_literal: true

module Sai
  class Model
    class RGB < Model
      CHANNEL_RANGE = 0..255
      HEX_BASE_FACTOR = 16
      HEX_PATTERN = /^#?([A-Fa-f0-9]{3}|[A-Fa-f0-9]{6})$/

      channel :red, :r, :linear, bounds: CHANNEL_RANGE
      channel :green, :g, :linear, bounds: CHANNEL_RANGE
      channel :blue, :b, :linear, bounds: CHANNEL_RANGE

      def self.from_hex(hex, **options)
        raise InvalidColorValueError, "`hex` #{hex.inspect} is invalid." unless HEX_PATTERN.match?(hex)

        hex = hex.delete_prefix('#')
        hex = hex.chars.map { |char| char * 2 }.join if hex.length == 3

        new(
          hex[0..1].to_i(HEX_BASE_FACTOR),
          hex[2..3].to_i(HEX_BASE_FACTOR),
          hex[4..5].to_i(HEX_BASE_FACTOR),
          **options,
        )
      end

      def to_cmyk(**options)
        convert_to(CMYK, **options) do
          nr, ng, nb = normalized = to_n_a
          k = 1.0 - normalized.max

          if k >= 1.0
            [0.0, 0.0, 0.0, 1.0]
          else
            [
              (1.0 - nr - k) / (1.0 - k),
              (1.0 - ng - k) / (1.0 - k),
              (1.0 - nb - k) / (1.0 - k),
              k,
            ]
          end
        end
      end

      def to_hsl(**options)
        convert_to(HSL, **options) do
          nr, ng, nb = normalized = to_n_a

          min = normalized.min
          max = normalized.max

          delta = (max - min).to_f
          l = (max + min) / 2.0

          if delta == 0.0
            h = 0
            s = 0
          else
            s = if l <= 0.5
                  delta / (max + min)
                else
                  delta / (2.0 - max - min)
                end

            h = if nr == max
                  ((ng - nb) / delta) % HSL::FULL_SECTOR
                elsif ng == max
                  ((nb - nr) / delta) + (HSL::FULL_SECTOR / 3.0)
                elsif nb == max
                  ((nr - ng) / delta) + ((HSL::FULL_SECTOR / 3.0) * 2.0)
                end

            h /= HSL::FULL_SECTOR
          end

          h = (h + 1) % 1 if h.negative?

          [h, s, l]
        end
      end

      def to_hsv(**options)
        convert_to(HSV, **options) do
          nr, ng, nb = normalized = to_n_a

          c_max = normalized.max
          c_min = normalized.min
          delta = c_max - c_min

          h = 0.0
          if delta != 0.0
            h = case c_max
                when nr
                  ((ng - nb) / delta) % HSV::FULL_SECTOR
                when ng
                  ((nb - nr) / delta) + (HSV::FULL_SECTOR / 3.0)
                when nb
                  ((nr - ng) / delta) + ((HSV::FULL_SECTOR / 3.0) * 2.0)
                end

            h /= HSV::FULL_SECTOR
          end

          s = c_max == 0.0 ? 0.0 : delta / c_max
          v = c_max

          [h, s, v]
        end
      end
      alias to_hsb to_hsv

      def to_rgb(**options)
        with_encoding_specification(**options)
      end

      def to_xyz(**options)
        convert_to(XYZ, **options) do |encoding_specification|
          matrix = encoding_specification.rgb_to_xyz_matrix
          linear = to_a.map { |channel| encoding_specification.color_space.gamma.to_linear(channel) }
          vector = matrix.class.column_vector(linear)
          (matrix * vector).to_a.flatten
        end
      end
    end
  end
end
