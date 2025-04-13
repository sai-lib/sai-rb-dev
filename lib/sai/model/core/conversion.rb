# frozen_string_literal: true

module Sai
  class Model
    module Core
      module Conversion
        class << self
          private

          def included(base)
            super

            base.extend ClassMethods
          end
        end

        module ClassMethods
          def coerce(other, **options)
            if other.is_a?(Array)
              new(*other, **options)
            elsif other.is_a?(Model)
              other.public_send(:"to_#{symbol}", encoding_specification: other.encoding_specification, **options)
            else
              raise TypeError, "`other` is invalid. Expected `Array | Sai::Model`, got: #{other.inspect}"
            end
          end

          def from_cmyk(...)
            from_model(CMYK, ...)
          end

          def from_hsl(...)
            from_model(HSL, ...)
          end

          def from_hsv(...)
            from_model(HSV, ...)
          end
          alias from_hsb from_hsv

          def from_lab(...)
            from_model(Lab, ...)
          end

          def from_lch(...)
            from_model(LCH, ...)
          end

          def from_luv(...)
            from_model(Luv, ...)
          end

          def from_oklab(...)
            from_model(Oklab, ...)
          end

          def from_oklch(...)
            from_model(Oklch, ...)
          end

          def from_rgb(...)
            from_model(RGB, ...)
          end

          def from_xyz(...)
            from_model(XYZ, ...)
          end

          private

          def from_model(model, *arguments, **options)
            instance = if arguments.size == 1 && arguments.first.is_a?(model)
                         arguments.first
                       elsif arguments.all?(Numeric)
                         model.new(*arguments, **options)
                       else
                         raise TypeError, "`#{model.symbol}` is invalid. Expected `Array[Numeric] | #{model}` got: " \
                                          "#{arguments.size == 1 ? arguments.first.inspect : arguments.map.join(', ')}"
                       end
            coerce(instance, encoding_specification: instance.encoding_specification, **options)
          end
        end

        def coerce(other, **options)
          if other.is_a?(Array)
            self.class.new(*other, encoding_specification:, **options)
          elsif other.is_a?(Model)
            other.public_send(:"to_#{symbol}", encoding_specification:, **options)
          else
            raise TypeError, "`other` is invalid. Expected `Array | Sai::Model`, got: #{other.inspect}"
          end
        end

        def to_cmyk(...)
          to_rgb(...).to_cmyk(...)
        end

        def to_grayscale(**options)
          r, g, b = to_rgb(encoding_specification:, **options).to_n_a
          bt709 = Formula::Contrast::BT709

          gray = (bt709::RED_COEFFICIENT * r) + (bt709::GREEN_COEFFICIENT * g) + (bt709::BLUE_COEFFICIENT * b)
          coerce(RGB.intermediate(gray, gray, gray, encoding_specification:, **options), **options)
        end

        def to_hsl(...)
          to_rgb(...).to_hsl(...)
        end

        def to_hsv(...)
          to_rgb(...).to_hsv(...)
        end
        alias to_hsb to_hsv

        def to_lab(...)
          to_xyz(...).to_lab(...)
        end

        def to_lch(...)
          to_lab(...).to_lch(...)
        end

        def to_lms(...)
          to_xyz(...).to_lms(...)
        end

        def to_luv(...)
          to_xyz(...).to_luv(...)
        end

        def to_oklab(...)
          to_lms(...).to_oklab(...)
        end

        def to_oklch(...)
          to_oklab(...).to_oklch(...)
        end

        def to_rgb(...)
          to_xyz(...).to_rgb(...)
        end

        def to_xyz(...)
          raise NotImplementedError, "`#{self.class}` does not implement `#to_xyz`"
        end

        def with_encoding_specification(**options)
          return self if options.empty?

          new_encoding_specification = encoding_specification(**options)
          return self if new_encoding_specification == default_encoding_specification

          color = coerce(to_xyz(encoding_specification: default_encoding_specification).to_xyz(**options), **options)
          strategy = gamut_mapping_strategy(**options)

          new_encoding_specification.map_to_gamut(color, strategy:)
        end

        private

        def convert_to(model, *cache_key_extra, **options)
          encoding_specification = encoding_specification(**options)

          cache_key = [
            self.class,
            :"to_#{model.symbol}",
            *channel_cache_key,
            *cache_key_extra,
            encoding_specification.to_h,
          ]

          channels = Sai.cache.fetch(*cache_key) { yield(encoding_specification) }

          model.intermediate(*channels, **options)
        end
      end
    end
  end
end
