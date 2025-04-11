# frozen_string_literal: true

module Sai
  class Model
    class Oklab < Model
      NON_LINEAR_LMS_MATRIX = Matrix[
        [0.8189330101, 0.3618667424, -0.1288597137],
        [0.0329845436, 0.9293118715, 0.0361456387],
        [0.0482003018, 0.2643662691, 0.6338517070],
      ].freeze

      channel :lightness, :l, :percentage, display_precision: 2, differential_step: 0.2
      channel :a, :a, :bipolar, display_precision: 2, differential_step: 0.2
      channel :b, :b, :bipolar, display_precision: 2, differential_step: 0.2

      cache_channels_with_high_precision

      def to_lms(**options)
        convert_to(LMS, **options) do
          matrix = NON_LINEAR_LMS_MATRIX.inverse
          vector = matrix.class.column_vector(self)
          nonlinear_lms = (matrix * vector).to_a.flatten
          nonlinear_lms.map { |channel| channel**3 }
        end
      end

      def to_oklab(**options)
        with_encoding_specification(**options)
      end

      def to_oklch(**options)
        convert_to(Oklch, **options) do
          nl, na, nb = to_n_a

          c = Math.sqrt((na * na) + (nb * nb))
          h = Math.atan2(nb, na) / (2 * Math::PI)
          h += 1.0 if h.negative?

          [nl, c, h]
        end
      end

      def to_xyz(...)
        to_lms(...).to_xyz(...)
      end
    end
  end
end
