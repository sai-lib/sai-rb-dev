# frozen_string_literal: true

module Sai
  module Space
    module Encoded
      class RGB
        module XYZMatrix
          class << self
            def generate(white_point, primaries)
              unless Model::XYZ === white_point
                raise TypeError, '`white_point` is invalid. Expected an object that implements `Sai::Model::XYZ` or ' \
                                 "`[Numeric, Numeric, Numeric]` got: #{white_point.inspect}"
              end

              unless primaries.all?(Chromaticity)
                raise TypeError, '`primaries` are invalid. Expected `Array[Sai::Chromaticity]`, ' \
                                 "got: #{primaries.inspect}"
              end

              rows = Sai.cache.fetch(XYZMatrix, :generate, white_point.identity, *primaries.map(&:identity)) do
                r_xyz, g_xyz, b_xyz = primaries.map(&:to_tristimulus)

                primary_matrix = Sai::Core::Matrix[
                  [r_xyz.x, g_xyz.x, b_xyz.x],
                  [r_xyz.y, g_xyz.y, b_xyz.y],
                  [r_xyz.z, g_xyz.z, b_xyz.z],
                ]

                white_point_vector = Sai::Core::Matrix.column_vector(white_point)
                scaling_vector = primary_matrix.inverse * white_point_vector
                sr, sg, sb = scaling_vector.to_a.flatten

                scaling_matrix = Sai::Core::Matrix[
                  [sr, 0, 0],
                  [0, sg, 0],
                  [0, 0, sb],
                ]

                (primary_matrix * scaling_matrix).to_a
              end

              Sai::Core::Matrix[*rows]
            end
          end
        end
      end
    end
  end
end
