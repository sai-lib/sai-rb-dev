# frozen_string_literal: true

module Sai
  module Chromaticity
    class UV < Base
      implements Model::UV

      class << self
        def coerce(other)
          return other if other.is_a?(self)
          return new(*other) if other.is_a?(Array) && components.valid?(*other)
          return from_xy(other) if other.is_a?(XY)
          return from_xyz(other) if Model::XYZ === other

          raise ArgumentError, "#{other.inspect} is not coercible to #{self}"
        end

        def from_xy(xy, luminance = 1.0)
          unless Model::XY === xy
            raise TypeError,
                  "`xy` is invalid. Expected `Sai::Chromaticity::XY | [Numeric, Numeric], got `#{xy.inspect}`"
          end

          from_xyz(XY.coerce(xy).to_tristimulus(luminance))
        end

        def from_xyz(xyz)
          unless Model::XYZ === xyz
            raise TypeError,
                  "`xyz` is invalid. Expected an object that implements `Sai::Model::XYZ`, got `#{xyz.class}`"
          end

          xyz = Spectral::Tristimulus.coerce(xyz)

          u, v = Sai.cache.fetch(UV, :from_xyz, xyz.identity) do
            x, y, z = xyz.to_a
            denominator = x + (15 * y) + (3 * z)

            if denominator.zero?
              [0.0, 0.0]
            else
              [(4 * x) / denominator, (9 * y) / denominator]
            end
          end

          new(u, v)
        end
      end

      def to_tristimulus(luminance = 1.0)
        x, y, z = Sai.cache.fetch(UV, :to_tristimulus, identity, luminance) do
          nu, nv = to_a
          y = luminance.to_f

          if nv.zero?
            [0.0, 0.0, 0.0]
          else
            x = (9 * nu * y) / (4 * nv)
            z = ((12 - (3 * nu) - (20 * nv)) * y) / (4 * nv)
            [x, y, z]
          end
        end

        Spectral::Tristimulus.new(x, y, z)
      end

      def to_uv(luminance = 1.0)
        self.class.from_xyz(to_tristimulus(luminance))
      end

      def to_xy(luminance = 1.0)
        XY.from_xyz(to_tristimulus(luminance))
      end
    end
  end
end
