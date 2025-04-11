# frozen_string_literal: true

module Sai
  class Model
    class XYZ < Model
      channel :x, :x, :linear, display_precision: 6, differential_step: 0.001
      channel :y, :y, :linear, display_precision: 6, differential_step: 0.001
      channel :z, :z, :linear, display_precision: 6, differential_step: 0.001

      cache_channels_with_high_precision

      def to_lab(**options)
        convert_to(Lab, **options) do |encoding_specification|
          reference_white = encoding_specification.adapted_white_point

          relative = to_n_a.zip(reference_white.to_n_a).map { |rel, ref| rel / ref }

          fx, fy, fz = relative.map do |channel|
            channel > Lab::DELTA_CUBED ? channel**(1.0 / 3.0) : (channel / (3.0 * Lab::DELTA_SQUARED)) + (4.0 / 29.0)
          end

          [
            ((116.0 * fy) - 16.0) / PERCENTAGE_RANGE.end,
            500.0 * (fx - fy),
            200.0 * (fy - fz),
          ]
        end
      end

      def to_lms(**options)
        convert_to(LMS, **options) do |encoding_specification|
          cat = encoding_specification.chromatic_adaptation_transform
          vector = cat.class.column_vector(self)
          (cat * vector).to_a.flatten
        end
      end

      def to_luv(**options)
        convert_to(Luv, **options) do |encoding_specification|
          nx, ny, nz = to_n_a
          white_point = encoding_specification.adapted_white_point

          wpx, wpy, wpz = white_point.to_n_a

          un_prime = 4.0 * wpx / (wpx + (15.0 * wpy) + (3.0 * wpz))
          vn_prime = 9.0 * wpy / (wpx + (15.0 * wpy) + (3.0 * wpz))

          denominator = nx + (15.0 * ny) + (3.0 * nz)
          return [0.0, 0.0, 0.0] if denominator.zero?

          u_prime = 4.0 * nx / denominator
          v_prime = 9.0 * ny / denominator

          l = if ny / wpy > 0.008856
                (116.0 * ((ny / wpy)**(1.0 / 3.0))) - 16.0
              else
                903.3 * (ny / wpy)
              end

          u = 13.0 * l * (u_prime - un_prime)
          v = 13.0 * l * (v_prime - vn_prime)

          l_normalized = l / 100.0
          u_normalized = (u + 100.0) / 200.0
          v_normalized = (v + 100.0) / 200.0

          [l_normalized, u_normalized, v_normalized]
        end
      end

      def to_rgb(**options)
        convert_to(RGB, **options) do |encoding_specification|
          matrix = encoding_specification.xyz_to_rgb_matrix
          vector = matrix.class.column_vector(self)
          linear = (matrix * vector).to_a.flatten
          linear.map { |channel| encoding_specification.color_space.gamma.from_linear(channel) }
        end
      end

      def to_xyz(**options)
        return self if options.empty?

        new_encoding_specification = encoding_specification(**options)
        return self if new_encoding_specification == default_encoding_specification

        convert_to(XYZ, **options) do |encoding_spec|
          source_white = default_encoding_specification.adapted_white_point
          target_white = encoding_spec.adapted_white_point

          if source_white == target_white
            to_n_a
          else
            encoding_spec.chromatic_adaptation_transform.adapt(self, source_white:, target_white:).to_n_a
          end
        end
      end
    end
  end
end
