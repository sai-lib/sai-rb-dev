# frozen_string_literal: true

module Sai
  module Space
    module Core
      module Introspection
        class << self
          private

          def included(base)
            super

            base.extend  ClassMethods
            base.include Sai::Core::Concurrency
            base.include BasicInstanceMethods
            base.include EncodedInstanceMethods
            base.include PerceptualInstanceMethods
            base.include PhysiologicalInstanceMethods
          end
        end

        module BasicInstanceMethods
          def chromaticity_uv
            concurrent_instance_variable_fetch(
              :@chromaticity_uv,
              Chromaticity.from_xyz(to_xyz, Chromaticity::UV),
            )
          end

          def chromaticity_xy
            concurrent_instance_variable_fetch(
              :@chromaticity_xy,
              Chromaticity.from_xyz(to_xyz),
            )
          end
          alias chromaticity chromaticity_xy

          def correlated_color_temperature
            concurrent_instance_variable_fetch(
              :@correlated_color_temperature,
              Sai.config.default_correlated_color_temperature_formula.calculate(chromaticity),
            )
          end
          alias cct         correlated_color_temperature
          alias temperature correlated_color_temperature

          def identifier
            concurrent_instance_variable_fetch(:@identifier, self.class.identifier)
          end

          def inspect
            to_string
          end

          private

          def identity_attributes
            [
              self.class,
              components.identity,
              local_context&.identity,
            ].compact.freeze
          end
        end

        module ClassMethods
          attr_reader :model

          def identifier
            concurrent_instance_variable_fetch(
              :@identifier,
              Sai::Core::Inflection.snake_case(name.split('::').last).to_sym,
            )
          end
        end

        module EncodedInstanceMethods
          def blue
            concurrent_instance_variable_fetch(:@blue, to_rgb.blue)
          end

          def blue_hexadecimal
            hexadecimal.delete_prefix('#')[4..5]
          end
          alias blue_hex blue_hexadecimal

          def brightness
            concurrent_instance_variable_fetch(:@brightness, to_hsb.brightness)
          end

          def cyan
            concurrent_instance_variable_fetch(:@cyan, to_cmyk.cyan)
          end

          def encoded?
            is_a?(Space::Encoded)
          end

          def green
            concurrent_instance_variable_fetch(:@green, to_rgb.green)
          end

          def green_hexadecimal
            hexadecimal.delete_prefix('#')[2..3]
          end
          alias green_hex green_hexadecimal

          def hexadecimal
            concurrent_instance_variable_fetch(
              :@hexadecimal,
              format('#%<red>02X%<green>02X%<blue>02X', red:, green:, blue:),
            )
          end
          alias hex hexadecimal

          def magenta
            concurrent_instance_variable_fetch(:@magenta, to_cmyk.magenta)
          end

          def red
            concurrent_instance_variable_fetch(:@red, to_rgb.red)
          end

          def red_hexadecimal
            hexadecimal.delete_prefix('#')[0..1]
          end
          alias red_hex red_hexadecimal

          def saturation
            concurrent_instance_variable_fetch(:@saturation, to_hsl.saturation)
          end

          def yellow
            concurrent_instance_variable_fetch(:@yellow, to_cmyk.yellow)
          end
        end

        module PerceptualInstanceMethods
          def chroma
            concurrent_instance_variable_fetch(:@chroma, to_oklch.chroma)
          end

          def hue
            concurrent_instance_variable_fetch(:@hue, to_oklch.hue)
          end

          def perceptual?
            is_a?(Space::Perceptual)
          end

          def perceptual_brightness
            concurrent_instance_variable_fetch(:@perceptual_brightness, to_oklch.lightness)
          end
          alias perceptual_lightness perceptual_brightness

          def perceptual_saturation
            concurrent_instance_variable_fetch(
              :@perceptual_saturation,
              begin
                l, c, = to_oklch.to_a
                if l.zero?
                  0.0
                else
                  ([c / (l * 2.0), 1.0].min * PERCENTAGE_RANGE.end).round(2)
                end
              end,
            )
          end
        end

        module PhysiologicalInstanceMethods
          def luminance
            concurrent_instance_variable_fetch(@luminance, to_xyz.y.normalized)
          end

          def luminance_percentage
            (luminance * PERCENTAGE_RANGE.end).round(2)
          end

          def physiological?
            is_a?(Space::Physiological)
          end
        end
      end
    end
  end
end
