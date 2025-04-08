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
    end
  end
end
