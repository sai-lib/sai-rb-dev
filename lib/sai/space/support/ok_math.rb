# frozen_string_literal: true

module Sai
  module Space
    module Support
      module OkMath
        K1 = 0.206
        K2 = 0.03
        K3 = (1.0 + K1) / (1.0 + K2)

        class << self
          def cusp_for_component(a, b, component)
            rgb = case component
                  when :r then [1.0, 0.0, 0.0]
                  when :g then [0.0, 1.0, 0.0]
                  when :b then [0.0, 0.0, 1.0]
                  else raise ArgumentError, "Invalid channel: #{component}"
                  end

            rgb_matrix = Perceptual::Oklab::LINEAR_RGB_MATRIX
            lms = (rgb_matrix * rgb_matrix.column_vector(rgb)).to_a.flatten

            lms_matrix = Perceptual::Oklab::LINEAR_LMS_MATRIX
            linear_lms = lms.map { |c| c**(1.0 / 3.0) }
            lc, ac, bc = (lms_matrix * lms_matrix.column_vector(linear_lms)).to_a.flatten

            c_cusp = (a * ac) + (b * bc)
            [lc, c_cusp].freeze
          end

          def find_cusp(h)
            a = Math.cos(2 * Math::PI * h)
            b = Math.sin(2 * Math::PI * h)

            cusp_r = cusp_for_component(a, b, :r)
            cusp_g = cusp_for_component(a, b, :g)
            cusp_b = cusp_for_component(a, b, :b)

            [cusp_r, cusp_g, cusp_b].max_by(&:last)
          end

          def max_chroma_for_lightness(cusp, l)
            if l < cusp.first
              cusp.last * l / cusp.first
            else
              cusp.last * (1 - l) / (1 - cusp.first)
            end
          end

          def toe(x)
            0.5 * ((K3 * x) - K1 + Math.sqrt((((K3 * x) - K1)**2) + (4 * K2 * K3 * x)))
          end

          def toe_inv(x)
            ((x**2) + (K1 * x)) / (K3 * (x + K2))
          end
        end
      end
    end
  end
end
