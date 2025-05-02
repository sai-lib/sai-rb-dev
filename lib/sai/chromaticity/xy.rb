# frozen_string_literal: true

module Sai
  module Chromaticity
    class XY < Base
      implements Model::XY

      class << self
        def coerce(other)
          return other if other.is_a?(self)
          return new(*other) if other.is_a?(Array) && components.valid?(*other)
          return from_uv(other) if other.is_a?(UV)
          return from_xyz(other) if Model::XYZ === other

          raise ArgumentError, "#{other.inspect} is not coercible to #{self}"
        end

        def from_uv(uv, luminance = 1.0)
          unless Model::UV === uv
            raise TypeError,
                  "`uv` is invalid. Expected `Sai::Chromaticity::UV | [Numeric, Numeric], got `#{uv.inspect}`"
          end

          from_xyz(UV.coerce(uv).to_tristimulus(luminance))
        end

        def from_xyz(xyz)
          unless Model::XYZ === xyz
            raise TypeError, "`xyz` is invalid. Expected `Space::Physiological::XYZ`, got `#{xyz.class}`"
          end

          xyz = Spectral::Tristimulus.coerce(xyz)

          x, y = Sai.cache.fetch(XY, :from_xyz, *xyz.identity) do
            x, y, z = xyz.components.map(&:normalized)
            sum = x + y + z

            if sum.zero?
              [0.0, 0.0]
            else
              [x / sum, y / sum]
            end
          end

          new(x, y)
        end
      end

      def to_tristimulus(luminance = 1.0)
        nx, ny, z = Sai.cache.fetch(XY, :to_tristimulus, identity, luminance) do
          nx, ny = to_a
          luminance = luminance.to_f

          if ny.zero?
            [0.0, 0.0, 0.0]
          else
            z = 1.0 - nx - ny
            [(nx / ny) * luminance, luminance, (z / ny) * luminance]
          end
        end

        Spectral::Tristimulus.new(nx, ny, z)
      end

      def to_uv(luminance = 1.0)
        UV.from_xyz(to_tristimulus(luminance))
      end

      def to_xy(luminance = 1.0)
        self.class.from_xyz(to_tristimulus(luminance))
      end
    end
  end
end
