# frozen_string_literal: true

module Sai
  module Space
    module Physiological
      class XYZ < Base
        implements Model::XYZ

        def to_hunter_lab(**options)
          convert_to(Perceptual::HunterLab, **options) do |context|
            nx, ny, nz    = to_xyz(**context.to_h).to_a
            rnx, rny, rnz = context.white_point.to_a
            p_max         = PERCENTAGE_RANGE.end

            ka = (175 / 198.04) * (rnx + rny)
            kb = (70.0 / 218.11) * (rny + rnz)

            l = Math.sqrt(ny / rny)
            a = (ka * (((nx / rnx) - (ny / rny)) / Math.sqrt(ny / rny))) * p_max
            b = (kb * (((ny / rny) - (nz / rnz)) / Math.sqrt(ny / rny))) * p_max
            [l, a, b]
          end
        end

        def to_lab(**options)
          space = case __callee__
                  when :to_lab_d65 then Perceptual::Lab::D65
                  else Perceptual::Lab::D50
                  end

          convert_to(space, **options) do |context|
            relative = to_xyz(**context.to_h).to_a.zip(context.white_point.to_a).map { |rel, ref| rel / ref }

            fx, fy, fz = relative.map do |component|
              if component > Perceptual::Lab::DELTA_CUBED
                component**(1.0 / 3.0)
              else
                (component / (3.0 * Perceptual::Lab::DELTA_SQUARED)) + (4.0 / 29.0)
              end
            end

            [
              ((116.0 * fy) - 16.0) / PERCENTAGE_RANGE.end,
              500.0 * (fx - fy),
              200.0 * (fy - fz),
            ]
          end
        end
        alias to_lab_d50 to_lab
        alias to_lab_d65 to_lab

        def to_lms(**options)
          convert_to(LMS, **options) { |context| context.cone_transform.xyz_to_lms(to_xyz(**context.to_h)) }
        end

        def to_luv(**options)
          convert_to(Perceptual::Luv, **options) do |context|
            nx, ny, nz    = to_xyz(**context.to_h).to_a
            wpx, wpy, wpz = context.white_point.to_a

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

        def to_oklab(**options)
          convert_to(Perceptual::Oklab, **options) do |context|
            xyz = with_context(**context.to_h).to_a

            m1 = Perceptual::Oklab::M1
            m2 = Perceptual::Oklab::M2

            lms = (m1 * m1.column_vector(xyz)).to_a.flatten
            prime = lms.map { |component| component**(1.0 / 3.0) }
            (m2 * m2.column_vector(prime)).to_a.flatten
          end
        end

        def to_rgb(**options)
          rgb_space = options.fetch(:rgb_space, Sai.config.default_rgb_space)

          convert_to(rgb_space, map_to_gamut: true, **options) do |context|
            matrix = rgb_space.from_xyz_matrix
            linear = (matrix * matrix.column_vector(to_xyz(**context.to_h))).to_a.flatten
            linear.map { |component| rgb_space.from_linear(component) }
          end
        end

        def to_xyz(...)
          convert_to_self(...)
        end
      end
    end
  end
end
