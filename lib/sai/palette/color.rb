# frozen_string_literal: true

module Sai
  class Palette
    class Color
      attr_reader :name

      def initialize(name, value)
        @name = name.to_sym
        @value = value.to_xyz(encoding_specification: value.encoding_specification)
      end

      def as_cmyk(**options)
        @value.to_cmyk(encoding_specification: build_encoding_specification(**options))
      end

      def as_hsl(**options)
        @value.to_hsl(encoding_specification: build_encoding_specification(**options))
      end

      def as_hsv(**options)
        @value.to_hsv(encoding_specification: build_encoding_specification(**options))
      end
      alias as_hsb as_hsv

      def as_lab(**options)
        @value.to_lab(encoding_specification: build_encoding_specification(**options))
      end

      def as_lch(**options)
        @value.to_lch(encoding_specification: build_encoding_specification(**options))
      end

      def as_lms(**options)
        @value.to_lms(encoding_specification: build_encoding_specification(**options))
      end

      def as_luv(**options)
        @value.to_luv(encoding_specification: build_encoding_specification(**options))
      end

      def as_oklab(**options)
        @value.to_oklab(encoding_specification: build_encoding_specification(**options))
      end

      def as_oklch(**options)
        @value.to_oklch(encoding_specification: build_encoding_specification(**options))
      end

      def as_rgb(**options)
        @value.to_rgb(encoding_specification: build_encoding_specification(**options))
      end

      def as_xyz(**options)
        @value.to_xyz(encoding_specification: build_encoding_specification(**options))
      end

      def to_string
        @value.to_string
      end
      alias inspect to_string
      alias to_s    to_string

      private

      def build_encoding_specification(**options)
        if options.key?(:encoding_specification)
          encoding_specification = options[:encoding_specification]
          unless encoding_specification.is_a?(EncodingSpecification)
            raise TypeError, '`:encoding_specification` is invalid. Expected `Sai::EncodingSpecification`, ' \
                             "got: #{encoding_specification.inspect}"
          end
          encoding_specification
        elsif options.key?(:color_space)
          color_space = Enum.resolve(options[:color_space])

          unless color_space.is_a?(Space)
            raise TypeError, "`:color_space` is invalid. Expected a `Sai::Space` got: #{color_space.inspect}"
          end

          Enum.resolve(
            chromatic_adaptation_transform = options.fetch(
              :chromatic_adaptation_transform,
              options.fetch(:cat, color_space.chromatic_adaptation_transform),
            ),
          )

          illuminant = Enum.resolve(options.fetch(:illuminant, color_space.illuminant))

          observer = Enum.resolve(options.fetch(:observer, color_space.observer))

          viewing_condition = Enum.resolve(options.fetch(:viewing_condition, Sai.config.default_viewing_condition))

          EncodingSpecification.new(
            chromatic_adaptation_transform:,
            color_space:,
            illuminant:,
            observer:,
            viewing_condition:,
          )
        else
          @value.encoding_specification
        end
      end

      def method_missing(method_name, ...)
        return super unless respond_to_missing?(method_name)

        @value.public_send(method_name, ...)
      end

      def respond_to_missing?(method_name, _include_private = false)
        @value.respond_to?(method_name) || super
      end
    end
  end
end
