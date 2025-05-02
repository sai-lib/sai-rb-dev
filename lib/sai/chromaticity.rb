# frozen_string_literal: true

module Sai
  module Chromaticity
    autoload :Base, 'sai/chromaticity/base'
    autoload :UV,   'sai/chromaticity/uv'
    autoload :XY,   'sai/chromaticity/xy'

    class << self
      def ===(other)
        other.is_a?(self) || super
      end

      def from_xyz(xyz, model = XY)
        unless Model::XYZ === xyz
          raise TypeError, '`:xyz` is invalid. Expected an object that implements `Sai::Model::XYZ` or ' \
                           "`[Numeric, Numeric, Numeric]` got: #{xyz.inspect}"
        end

        unless model.is_a?(Class) && model.name.start_with?(name)
          raise TypeError, "`model` is invalid. Expected a child of `#{name}`, got `#{model.inspect}`"
        end

        model.from_xyz(xyz)
      end

      def uv(u, v)
        UV.new(u, v)
      end

      def xy(x, y)
        XY.new(x, y)
      end
    end
  end
end
