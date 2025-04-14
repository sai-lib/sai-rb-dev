# frozen_string_literal: true

module Sai
  class Model
    module Core
      module Introspection
        class << self
          private

          def included(base)
            super

            base.extend ClassMethods
          end
        end

        module ClassMethods
          using Inflection::CaseRefinements

          def symbol
            @symbol ||= name.split('::').last.to_snake_case.to_sym
          end
        end

        def blue
          @blue ||= to_rgb(encoding_specification:).blue
        end

        def brightness
          @brightness ||= to_hsv(encoding_specification:).brightness
        end

        def chroma
          @chroma ||= to_oklch(encoding_specification:).chroma
        end

        def correlated_color_temperature(formula: Sai.config.default_correlated_color_temperature_formula)
          @correlated_color_temperature ||= begin
            formula = Enum.resolve(formula)
            unless formula.name.start_with?(Formula::CorrelatedColorTemperature.name)
              raise ArgumentError,
                    "`:formula` is invalid. Expected `Sai::Formula::CorrelatedColorTemperature got: #{formula.inspect}"
            end

            chromaticity = Chromaticity.from_xyz(to_xyz(encoding_specification:))
            formula.calculate(chromaticity)
          end
        end
        alias cct correlated_color_temperature
        alias temperature correlated_color_temperature

        def cyan
          @cyan ||= to_cmyk(encoding_specification:).cyan
        end

        def green
          @green ||= to_rgb(encoding_specification:).green
        end

        def hash
          to_n_a.hash
        end

        def hue
          @hue ||= to_oklch(encoding_specification:).hue
        end

        def lightness
          @lightness ||= to_oklch(encoding_specification:).lightness
        end

        def magenta
          @magenta ||= to_cmyk(encoding_specification:).magenta
        end

        def perceptual_brightness
          @perceptual_brightness ||= to_oklch(encoding_specification:).lightness
        end
        alias perceptual_lightness perceptual_brightness

        def perceptual_saturation
          @perceptual_saturation ||= begin
            oklch = to_oklch(encoding_specification:)
            if oklch.lightness.zero?
              0.0
            else
              [oklch.chroma / (oklch.lightness * 2.0), 1.0].min
            end
          end
        end

        def red
          @red ||= to_rgb(encoding_specification:).red
        end

        def saturation
          @saturation ||= to_hsl(encoding_specification:).saturation
        end

        def symbol
          @symbol ||= self.class.symbol
        end

        def to_array
          model = with_opacity_flattened
          self.class.channels.map { |channel| model.instance_variable_get(:"@#{channel.symbol}") }
        end
        alias to_a to_array

        def to_normalized_array
          to_array.map(&:normalized)
        end
        alias to_n_a to_normalized_array

        def to_string
          display_symbol = symbol

          channels = self.class.channels.map { |channel| instance_variable_get(:"@#{channel.symbol}").to_s }

          if opacity < PERCENTAGE_RANGE.end
            channels << format('%.1f%%', opacity)
            display_symbol = "#{display_symbol}a"
          end

          "#{display_symbol}(#{channels.join(', ')})".freeze
        end
        alias inspect to_string
        alias to_s    to_string

        def to_unnormalized_array
          to_array.map(&:unnormalized)
        end
        alias to_un_a to_unnormalized_array

        def yellow
          @yellow ||= to_cmyk(encoding_specification:).yellow
        end
      end
    end
  end
end
