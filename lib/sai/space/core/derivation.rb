# frozen_string_literal: true

module Sai
  module Space
    module Core
      module Derivation
        class << self
          private

          def included(base)
            super

            base.include EncodedInstanceMethods
            base.include PerceptualInstanceMethods
            base.include PhysiologicalInstanceMethods
          end
        end

        module EncodedInstanceMethods
          class << self
            private

            def included(base)
              super

              base.include CMYK
              base.include Munsell
              base.include RGB
            end
          end

          module CMYK
            def with_cyan(value)
              coerce(to_cmyk.with_cyan(value))
            end

            def with_cyan_contracted_by(amount)
              coerce(to_cmyk.with_cyan_contracted_by(amount))
            end
            alias contract_cyan with_cyan_contracted_by

            def with_cyan_decremented_by(amount = Encoded::CMYK.components.cyan.differential_step)
              coerce(to_cmyk.with_cyan_decremented_by(amount))
            end
            alias decrement_cyan with_cyan_decremented_by

            def with_cyan_incremented_by(amount = Encoded::CMYK.components.cyan.differential_step)
              coerce(to_cmyk.with_cyan_incremented_by(amount))
            end
            alias increment_cyan with_cyan_incremented_by

            def with_cyan_scaled_by(amount)
              coerce(to_cmyk.with_cyan_scaled_by(amount))
            end
            alias scale_cyan with_cyan_scaled_by

            def with_magenta(value)
              coerce(to_cmyk.with_magenta(value))
            end

            def with_magenta_contracted_by(amount)
              coerce(to_cmyk.with_magenta_contracted_by(amount))
            end
            alias contract_magenta with_magenta_contracted_by

            def with_magenta_decremented_by(amount = Encoded::CMYK.components.magenta.differential_step)
              coerce(to_cmyk.with_magenta_decremented_by(amount))
            end
            alias decrement_magenta with_magenta_decremented_by

            def with_magenta_incremented_by(amount = Encoded::CMYK.components.magenta.differential_step)
              coerce(to_cmyk.with_magenta_incremented_by(amount))
            end
            alias increment_magenta with_magenta_incremented_by

            def with_magenta_scaled_by(amount)
              coerce(to_cmyk.with_magenta_scaled_by(amount))
            end
            alias scale_magenta with_magenta_scaled_by

            def with_yellow(value)
              coerce(to_cmyk.with_yellow(value))
            end

            def with_yellow_contracted_by(amount)
              coerce(to_cmyk.with_yellow_contracted_by(amount))
            end
            alias contract_yellow with_yellow_contracted_by

            def with_yellow_decremented_by(amount = Encoded::CMYK.components.yellow.differential_step)
              coerce(to_cmyk.with_yellow_decremented_by(amount))
            end
            alias decrement_yellow with_yellow_decremented_by

            def with_yellow_incremented_by(amount = Encoded::CMYK.components.yellow.differential_step)
              coerce(to_cmyk.with_yellow_incremented_by(amount))
            end
            alias increment_yellow with_yellow_incremented_by

            def with_yellow_scaled_by(amount)
              coerce(to_cmyk.with_yellow_scaled_by(amount))
            end
            alias scale_yellow with_yellow_scaled_by
          end

          module RGB
            def inverted
              coerce(
                Sai.config.default_rgb_space.new(
                  255.0 - red,
                  255.0 - green,
                  255.0 - blue,
                ),
              )
            end

            def with_blue(value)
              coerce(to_rgb.with_blue(value))
            end

            def with_blue_contracted_by(amount)
              coerce(to_rgb.with_blue_contracted_by(amount))
            end
            alias contract_blue with_blue_contracted_by

            def with_blue_decremented_by(amount = Encoded::RGB.components.blue.differential_step)
              coerce(to_rgb.with_blue_decremented_by(amount))
            end
            alias decrement_blue with_blue_decremented_by

            def with_blue_incremented_by(amount = Encoded::RGB.components.blue.differential_step)
              coerce(to_rgb.with_blue_incremented_by(amount))
            end
            alias increment_blue with_blue_incremented_by

            def with_blue_scaled_by(amount)
              coerce(to_rgb.with_blue_scaled_by(amount))
            end
            alias scale_blue with_blue_scaled_by

            def with_green(value)
              coerce(to_rgb.with_green(value))
            end

            def with_green_contracted_by(amount)
              coerce(to_rgb.with_green_contracted_by(amount))
            end
            alias contract_green with_green_contracted_by

            def with_green_decremented_by(amount = Encoded::RGB.components.green.differential_step)
              coerce(to_rgb.with_green_decremented_by(amount))
            end
            alias decrement_green with_green_decremented_by

            def with_green_incremented_by(amount = Encoded::RGB.components.green.differential_step)
              coerce(to_rgb.with_green_incremented_by(amount))
            end
            alias increment_green with_green_incremented_by

            def with_green_scaled_by(amount)
              coerce(to_rgb.with_green_scaled_by(amount))
            end
            alias scale_green with_green_scaled_by

            def with_red(value)
              coerce(to_rgb.with_red(value))
            end

            def with_red_contracted_by(amount)
              coerce(to_rgb.with_red_contracted_by(amount))
            end
            alias contract_red with_red_contracted_by

            def with_red_decremented_by(amount = Encoded::RGB.components.red.differential_step)
              coerce(to_rgb.with_red_decremented_by(amount))
            end
            alias decrement_red with_red_decremented_by

            def with_red_incremented_by(amount = Encoded::RGB.components.red.differential_step)
              coerce(to_rgb.with_red_incremented_by(amount))
            end
            alias increment_red with_red_incremented_by

            def with_red_scaled_by(amount)
              coerce(to_rgb.with_red_scaled_by(amount))
            end
            alias scale_red with_red_scaled_by
          end

          module Munsell
            def with_brightness(value)
              coerce(to_hsv.with_brightness(value))
            end

            def with_brightness_contracted_by(amount)
              coerce(to_hsv.with_brightness_contracted_by(amount))
            end
            alias contract_brightness with_brightness_contracted_by

            def with_brightness_decremented_by(amount = Encoded::HSV.components.brightness.differential_step)
              coerce(to_hsv.with_brightness_decremented_by(amount))
            end
            alias decrement_brightness with_brightness_decremented_by

            def with_brightness_incremented_by(amount = Encoded::HSV.components.brightness.differential_step)
              coerce(to_hsv.with_brightness_incremented_by(amount))
            end
            alias increment_brightness with_brightness_incremented_by

            def with_brightness_scaled_by(amount)
              coerce(to_hsv.with_brightness_scaled_by(amount))
            end
            alias scale_brightness with_brightness_scaled_by

            def with_lightness(value)
              coerce(to_hsl.with_lightness(value))
            end

            def with_lightness_contracted_by(amount)
              coerce(to_hsl.with_lightness_contracted_by(amount))
            end
            alias contract_lightness with_lightness_contracted_by

            def with_lightness_decremented_by(amount = Encoded::HSL.components.lightness.differential_step)
              coerce(to_hsl.with_lightness_decremented_by(amount))
            end
            alias decrement_lightness with_lightness_decremented_by

            def with_lightness_incremented_by(amount = Encoded::HSL.components.lightness.differential_step)
              coerce(to_hsl.with_lightness_incremented_by(amount))
            end
            alias increment_lightness with_lightness_incremented_by

            def with_lightness_scaled_by(amount)
              coerce(to_hsl.with_lightness_scaled_by(amount))
            end
            alias scale_lightness with_lightness_scaled_by

            def with_saturation(value)
              coerce(to_hsl.with_saturation(value))
            end

            def with_saturation_contracted_by(amount)
              coerce(to_hsl.with_saturation_contracted_by(amount))
            end
            alias contract_saturation with_saturation_contracted_by

            def with_saturation_decremented_by(amount = Encoded::HSL.components.saturation.differential_step)
              coerce(to_hsl.with_saturation_decremented_by(amount))
            end
            alias decrement_saturation with_saturation_decremented_by

            def with_saturation_incremented_by(amount = Encoded::HSL.components.saturation.differential_step)
              coerce(to_hsl.with_saturation_incremented_by(amount))
            end
            alias increment_saturation with_saturation_incremented_by

            def with_saturation_scaled_by(amount)
              coerce(to_hsl.with_saturation_scaled_by(amount))
            end
            alias scale_saturation with_saturation_scaled_by
          end
        end

        module PerceptualInstanceMethods
          def brightened_by(amount = 20)
            amount /= PERCENTAGE_RANGE.max
            with_chroma_scaled_by([amount, 0.4].min)
          end

          def darkened_by(amount = 20)
            amount /= PERCENTAGE_RANGE.max
            with_perceptual_lightness_contracted_by(1.0 - amount)
          end

          def desaturated_by(amount = 20)
            amount /= PERCENTAGE_RANGE.max
            with_chroma_contracted_by(1.0 - amount)
          end

          def lightened_by(amount = 20)
            amount /= PERCENTAGE_RANGE.max
            with_perceptual_lightness_scaled_by(1.0 - amount)
          end

          def muted_by(amount = 40)
            amount /= PERCENTAGE_RANGE.max
            with_chroma_scaled_by(1.0 - amount)
          end

          def pastelized(lightness_increase: 20, chroma_reduction: 30)
            lightness_factor = 1.0 + (lightness_increase / 100.0)
            chroma_factor = 1.0 - (chroma_reduction / 100.0)

            new_lightness = [perceptual_lightness * lightness_factor, 100.0].min
            new_chroma    = [chroma * chroma_factor, 40.0].min
            with_perceptual_lightness(new_lightness).with_chroma(new_chroma)
          end

          def saturated_by(amount = 20)
            amount /= PERCENTAGE_RANGE.max
            with_chroma_scaled_by(1.0 + amount)
          end

          def with_chroma(value)
            coerce(to_oklch.with_chroma(value))
          end

          def with_chroma_contracted_by(amount)
            coerce(to_oklch.with_chroma_contracted_by(amount))
          end
          alias contract_chroma with_chroma_contracted_by

          def with_chroma_decremented_by(amount = Perceptual::Oklch.components.chroma.differential_step)
            coerce(to_oklch.with_chroma_decremented_by(amount))
          end
          alias decrement_chroma with_chroma_decremented_by

          def with_chroma_incremented_by(amount = Perceptual::Oklch.components.chroma.differential_step)
            coerce(to_oklch.with_chroma_incremented_by(amount))
          end
          alias increment_chroma with_chroma_incremented_by

          def with_chroma_scaled_by(amount)
            coerce(to_oklch.with_chroma_scaled_by(amount))
          end
          alias scale_chroma with_chroma_scaled_by

          def with_hue(value)
            coerce(to_oklch.with_hue(value))
          end

          def with_hue_contracted_by(amount)
            coerce(to_oklch.with_hue_contracted_by(amount))
          end
          alias contract_hue with_hue_contracted_by

          def with_hue_decremented_by(amount = Perceptual::Oklch.components.hue.differential_step)
            coerce(to_oklch.with_hue_decremented_by(amount))
          end
          alias decrement_hue with_hue_decremented_by

          def with_hue_incremented_by(amount = Perceptual::Oklch.components.hue.differential_step)
            coerce(to_oklch.with_hue_incremented_by(amount))
          end
          alias increment_hue with_hue_incremented_by

          def with_hue_scaled_by(amount)
            coerce(to_oklch.with_hue_scaled_by(amount))
          end
          alias scale_hue with_hue_scaled_by

          def with_perceptual_brightness(value)
            coerce(to_oklch.with_lightness(value))
          end
          alias with_perceptual_lightness with_perceptual_brightness

          def with_perceptual_brightness_contracted_by(amount)
            coerce(to_oklch.with_lightness_contracted_by(amount))
          end
          alias contract_perceptual_brightness          with_perceptual_brightness_contracted_by
          alias contract_perceptual_lightness           with_perceptual_brightness_contracted_by
          alias with_perceptual_lightness_contracted_by with_perceptual_brightness_contracted_by

          def with_perceptual_brightness_decremented_by(
            amount = Perceptual::Oklch.components.lightness.differential_step
          )
            coerce(to_oklch.with_lightness_decremented_by(amount))
          end
          alias decrement_perceptual_brightness          with_perceptual_brightness_decremented_by
          alias decrement_perceptual_lightness           with_perceptual_brightness_decremented_by
          alias with_perceptual_lightness_decremented_by with_perceptual_brightness_decremented_by

          def with_perceptual_brightness_incremented_by(amount = Perceptual::Oklch.components.l.differential_step)
            coerce(to_oklch.with_lightness_incremented_by(amount))
          end
          alias increment_perceptual_brightness          with_perceptual_brightness_incremented_by
          alias increment_perceptual_lightness           with_perceptual_brightness_incremented_by
          alias with_perceptual_lightness_incremented_by with_perceptual_brightness_incremented_by

          def with_perceptual_brightness_scaled_by(amount)
            coerce(to_oklch.with_lightness_scaled_by(amount))
          end
          alias scale_perceptual_brightness         with_perceptual_brightness_scaled_by
          alias scale_perceptual_lightness          with_perceptual_brightness_scaled_by
          alias with_perceptual_lightness_scaled_by with_perceptual_brightness_scaled_by

          def with_perceptual_saturation(value)
            l, = to_oklch.to_a
            new_saturation = [value, 1.0].min
            new_chroma = new_saturation * l * 2.0
            with_chroma(new_chroma)
          end

          def with_perceptual_saturation_contracted_by(amount)
            l, c, = to_oklch.to_a
            current_saturation = [c / (l * 2.0), 1.0].min
            new_saturation = current_saturation * (1.0 - amount)
            new_chroma = new_saturation * l * 2.0
            with_chroma(new_chroma)
          end
          alias contract_perceptual_saturation with_perceptual_saturation_contracted_by

          def with_perceptual_saturation_decremented_by(amount = 0.1)
            l, c, = to_oklch.to_a
            current_saturation = [c / (l * 2.0), 1.0].min
            new_saturation = [current_saturation - amount, 0.0].max
            new_chroma = new_saturation * l * 2.0
            with_chroma(new_chroma)
          end
          alias decrement_perceptual_saturation with_perceptual_saturation_decremented_by

          def with_perceptual_saturation_incremented_by(amount = 0.1)
            l, c, = to_oklch.to_a
            current_saturation = [c / (l * 2.0), 1.0].min
            new_saturation = [current_saturation + amount, 1.0].min
            new_chroma = new_saturation * l * 2.0
            with_chroma(new_chroma)
          end
          alias increment_perceptual_saturation with_perceptual_saturation_incremented_by

          def with_perceptual_saturation_scaled_by(amount)
            l, c, = to_oklch.to_a
            current_saturation = [c / (l * 2.0), 1.0].min
            new_saturation = current_saturation * amount
            new_chroma = [new_saturation * l * 2.0, 1.0].min
            with_chroma(new_chroma)
          end
          alias scale_perceptual_saturation with_perceptual_saturation_scaled_by
        end

        module PhysiologicalInstanceMethods
          def with_luminance(value)
            coerce(to_xyz.with_y(value))
          end

          def with_luminance_contracted_by(amount)
            coerce(to_xyz.with_y_contracted_by(amount))
          end
          alias contract_luminance with_luminance_contracted_by

          def with_luminance_decremented_by(amount = Physiological::XYZ.components.y.differential_step)
            coerce(to_xyz.with_y_decremented_by(amount))
          end
          alias decrement_luminance with_luminance_decremented_by

          def with_luminance_incremented_by(amount = Physiological::XYZ.components.y.differential_step)
            coerce(to_xyz.with_y_incremented_by(amount))
          end
          alias increment_luminance with_luminance_incremented_by

          def with_luminance_scaled_by(amount)
            coerce(to_xyz.with_y_scaled_by(amount))
          end
          alias scale_luminance with_luminance_scaled_by
        end
      end
    end
  end
end
