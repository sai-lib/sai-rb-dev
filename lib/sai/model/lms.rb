# frozen_string_literal: true

module Sai
  class Model
    class LMS < Model
      channel :long, :l, :linear, display_precision: 6, differential_step: 0.0005
      channel :medium, :m, :linear, display_precision: 6, differential_step: 0.0005
      channel :short, :s, :linear, display_precision: 6, differential_step: 0.0005

      cache_channels_with_high_precision

      def to_lms(**options)
        with_encoding_specification(**options)
      end

      def to_oklab(**options)
        convert_to(Oklab, **options) do
          nonlinear_lms = to_n_a.map { |channel| Math.cbrt(channel) }
          vector = Oklab::NON_LINEAR_LMS_MATRIX.class.column_vector(nonlinear_lms)
          (Oklab::NON_LINEAR_LMS_MATRIX * vector).to_a.flatten
        end
      end

      def to_xyz(**options)
        convert_to(XYZ, **options) do |encoding_specification|
          cat = encoding_specification.chromatic_adaptation_transform
          vector = cat.class.column_vector(self)
          inverse_cat = cat.inverse
          (inverse_cat * vector).to_a.flatten
        end
      end
    end
  end
end
