# frozen_string_literal: true

module Sai
  class Model
    class CMYK < Model
      channel :cyan, :c, :percentage, differential_step: 0.5
      channel :magenta, :m, :percentage, differential_step: 0.5
      channel :yellow, :y, :percentage, differential_step: 0.5
      channel :key, :k, :percentage, differential_step: 0.5

      def to_cmyk(**options)
        with_encoding_specification(**options)
      end

      def to_rgb(**options)
        convert_to(RGB, **options) do
          [
            (1.0 - c) * (1.0 - k),
            (1.0 - m) * (1.0 - k),
            (1.0 - y) * (1.0 - k),
          ]
        end
      end

      def to_xyz(...)
        to_rgb(...).to_xyz(...)
      end
    end
  end
end
