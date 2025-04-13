# frozen_string_literal: true

module Sai
  class Model
    module Core
      module Derivation
        def with_blue(value)
          coerce(to_rgb(encoding_specification:).with_blue(value))
        end

        def with_blue_contracted_by(amount)
          coerce(to_rgb(encoding_specification:).with_blue_contracted_by(amount))
        end
        alias contract_blue with_blue_contracted_by

        def with_blue_decremented_by(amount = RGB.channels.blue.differential_step)
          coerce(to_rgb(encoding_specification:).with_blue_decremented_by(amount))
        end
        alias decrement_blue with_blue_decremented_by

        def with_blue_incremented_by(amount = RGB.channels.blue.differential_step)
          coerce(to_rgb(encoding_specification:).with_blue_incremented_by(amount))
        end
        alias increment_blue with_blue_incremented_by

        def with_blue_scaled_by(amount)
          coerce(to_rgb(encoding_specification:).with_blue_scaled_by(amount))
        end
        alias scale_blue with_blue_scaled_by

        def with_brightness(value)
          coerce(to_hsv(encoding_specification:).with_brightness(value))
        end

        def with_brightness_contracted_by(amount)
          coerce(to_hsv(encoding_specification:).with_brightness_contracted_by(amount))
        end
        alias contract_brightness with_brightness_contracted_by

        def with_brightness_decremented_by(amount = HSV.channels.brightness.differential_step)
          coerce(to_hsv(encoding_specification:).with_brightness_decremented_by(amount))
        end
        alias decrement_brightness with_brightness_decremented_by

        def with_brightness_incremented_by(amount = HSV.channels.brightness.differential_step)
          coerce(to_hsv(encoding_specification:).with_brightness_incremented_by(amount))
        end
        alias increment_brightness with_brightness_incremented_by

        def with_brightness_scaled_by(amount)
          coerce(to_hsv(encoding_specification:).with_brightness_scaled_by(amount))
        end
        alias scale_brightness with_brightness_scaled_by

        def with_chroma(value)
          coerce(to_oklch(encoding_specification:).with_chroma(value))
        end

        def with_chroma_contracted_by(amount)
          coerce(to_oklch(encoding_specification:).with_chroma_contracted_by(amount))
        end
        alias contract_chroma with_chroma_contracted_by

        def with_chroma_decremented_by(amount = Oklch.channels.chroma.differential_step)
          coerce(to_oklch(encoding_specification:).with_chroma_decremented_by(amount))
        end
        alias decrement_chroma with_chroma_decremented_by

        def with_chroma_incremented_by(amount = Oklch.channels.chroma.differential_step)
          coerce(to_oklch(encoding_specification:).with_chroma_incremented_by(amount))
        end
        alias increment_chroma with_chroma_incremented_by

        def with_chroma_scaled_by(amount)
          coerce(to_oklch(encoding_specification:).with_chroma_scaled_by(amount))
        end
        alias scale_chroma with_chroma_scaled_by

        def with_cyan(value)
          coerce(to_cmyk(encoding_specification:).with_cyan(value))
        end

        def with_cyan_contracted_by(amount)
          coerce(to_cmyk(encoding_specification:).with_cyan_contracted_by(amount))
        end
        alias contract_cyan with_cyan_contracted_by

        def with_cyan_decremented_by(amount = CMYK.channels.cyan.differential_step)
          coerce(to_cmyk(encoding_specification:).with_cyan_decremented_by(amount))
        end
        alias decrement_cyan with_cyan_decremented_by

        def with_cyan_incremented_by(amount = CMYK.channels.cyan.differential_step)
          coerce(to_cmyk(encoding_specification:).with_cyan_incremented_by(amount))
        end
        alias increment_cyan with_cyan_incremented_by

        def with_cyan_scaled_by(amount)
          coerce(to_cmyk(encoding_specification:).with_cyan_scaled_by(amount))
        end
        alias scale_cyan with_cyan_scaled_by

        def with_green(value)
          coerce(to_rgb(encoding_specification:).with_green(value))
        end

        def with_green_contracted_by(amount)
          coerce(to_rgb(encoding_specification:).with_green_contracted_by(amount))
        end
        alias contract_green with_green_contracted_by

        def with_green_decremented_by(amount = RGB.channels.green.differential_step)
          coerce(to_rgb(encoding_specification:).with_green_decremented_by(amount))
        end
        alias decrement_green with_green_decremented_by

        def with_green_incremented_by(amount = RGB.channels.green.differential_step)
          coerce(to_rgb(encoding_specification:).with_green_incremented_by(amount))
        end
        alias increment_green with_green_incremented_by

        def with_green_scaled_by(amount)
          coerce(to_rgb(encoding_specification:).with_green_scaled_by(amount))
        end
        alias scale_green with_green_scaled_by

        def with_hue(value)
          coerce(to_oklch(encoding_specification:).with_hue(value))
        end

        def with_hue_contracted_by(amount)
          coerce(to_oklch(encoding_specification:).with_hue_contracted_by(amount))
        end
        alias contract_hue with_hue_contracted_by

        def with_hue_decremented_by(amount = Oklch.channels.hue.differential_step)
          coerce(to_oklch(encoding_specification:).with_hue_decremented_by(amount))
        end
        alias decrement_hue with_hue_decremented_by

        def with_hue_incremented_by(amount = Oklch.channels.hue.differential_step)
          coerce(to_oklch(encoding_specification:).with_hue_incremented_by(amount))
        end
        alias increment_hue with_hue_incremented_by

        def with_hue_scaled_by(amount)
          coerce(to_oklch(encoding_specification:).with_hue_scaled_by(amount))
        end
        alias scale_hue with_hue_scaled_by

        def with_lightness(value)
          coerce(to_hsl(encoding_specification:).with_lightness(value))
        end

        def with_lightness_contracted_by(amount)
          coerce(to_hsl(encoding_specification:).with_lightness_contracted_by(amount))
        end
        alias contract_lightness with_lightness_contracted_by

        def with_lightness_decremented_by(amount = HSL.channels.lightness.differential_step)
          coerce(to_hsl(encoding_specification:).with_lightness_decremented_by(amount))
        end
        alias decrement_lightness with_lightness_decremented_by

        def with_lightness_incremented_by(amount = HSL.channels.lightness.differential_step)
          coerce(to_hsl(encoding_specification:).with_lightness_incremented_by(amount))
        end
        alias increment_lightness with_lightness_incremented_by

        def with_lightness_scaled_by(amount)
          coerce(to_hsl(encoding_specification:).with_lightness_scaled_by(amount))
        end
        alias scale_lightness with_lightness_scaled_by

        def with_luminance(value)
          coerce(to_xyz(encoding_specification:).with_y(value))
        end

        def with_luminance_contracted_by(amount)
          xyz = to_xyz(encoding_specification:)
          new_y = xyz.y * (1.0 - amount)
          coerce(xyz.with_y(new_y))
        end
        alias contract_luminance with_luminance_contracted_by

        def with_luminance_decremented_by(amount = XYZ.channels.y.differential_step)
          xyz = to_xyz(encoding_specification:)
          new_y = [xyz.y - amount, 0.0].max
          coerce(xyz.with_y(new_y))
        end
        alias decrement_luminance with_luminance_decremented_by

        def with_luminance_incremented_by(amount = XYZ.channels.y.differential_step)
          xyz = to_xyz(encoding_specification:)
          new_y = [xyz.y + amount, 1.0].min
          coerce(xyz.with_y(new_y))
        end
        alias increment_luminance with_luminance_incremented_by

        def with_luminance_scaled_by(amount)
          xyz = to_xyz(encoding_specification:)
          new_y = xyz.y * amount
          coerce(xyz.with_y(new_y))
        end
        alias scale_luminance with_luminance_scaled_by

        def with_magenta(value)
          coerce(to_cmyk(encoding_specification:).with_magenta(value))
        end

        def with_magenta_contracted_by(amount)
          coerce(to_cmyk(encoding_specification:).with_magenta_contracted_by(amount))
        end
        alias contract_magenta with_magenta_contracted_by

        def with_magenta_decremented_by(amount = CMYK.channels.magenta.differential_step)
          coerce(to_cmyk(encoding_specification:).with_magenta_decremented_by(amount))
        end
        alias decrement_magenta with_magenta_decremented_by

        def with_magenta_incremented_by(amount = CMYK.channels.magenta.differential_step)
          coerce(to_cmyk(encoding_specification:).with_magenta_incremented_by(amount))
        end
        alias increment_magenta with_magenta_incremented_by

        def with_magenta_scaled_by(amount)
          coerce(to_cmyk(encoding_specification:).with_magenta_scaled_by(amount))
        end
        alias scale_magenta with_magenta_scaled_by

        def with_perceptual_brightness(value)
          coerce(to_oklch(encoding_specification:).with_lightness(value))
        end

        def with_perceptual_brightness_contracted_by(amount)
          coerce(to_oklch(encoding_specification:).with_lightness_contracted_by(amount))
        end
        alias contract_perceptual_brightness with_perceptual_brightness_contracted_by

        def with_perceptual_brightness_decremented_by(amount = Oklch.channels.lightness.differential_step)
          coerce(to_oklch(encoding_specification:).with_lightness_decremented_by(amount))
        end
        alias decrement_perceptual_brightness with_perceptual_brightness_decremented_by

        def with_perceptual_brightness_incremented_by(amount = Oklch.channels.lightness.differential_step)
          coerce(to_oklch(encoding_specification:).with_lightness_incremented_by(amount))
        end
        alias increment_perceptual_brightness with_perceptual_brightness_incremented_by

        def with_perceptual_brightness_scaled_by(amount)
          coerce(to_oklch(encoding_specification:).with_lightness_scaled_by(amount))
        end
        alias scale_perceptual_brightness with_perceptual_brightness_scaled_by

        def with_perceptual_lightness(value)
          coerce(to_oklch(encoding_specification:).with_lightness(value))
        end

        def with_perceptual_lightness_contracted_by(amount)
          coerce(to_oklch(encoding_specification:).with_lightness_contracted_by(amount))
        end
        alias contract_perceptual_lightness with_perceptual_lightness_contracted_by

        def with_perceptual_lightness_decremented_by(amount = Oklch.channels.lightness.differential_step)
          coerce(to_oklch(encoding_specification:).with_lightness_decremented_by(amount))
        end
        alias decrement_perceptual_lightness with_perceptual_lightness_decremented_by

        def with_perceptual_lightness_incremented_by(amount = Oklch.channels.lightness.differential_step)
          coerce(to_oklch(encoding_specification:).with_lightness_incremented_by(amount))
        end
        alias increment_perceptual_lightness with_perceptual_lightness_incremented_by

        def with_perceptual_lightness_scaled_by(amount)
          coerce(to_oklch(encoding_specification:).with_lightness_scaled_by(amount))
        end
        alias scale_perceptual_lightness with_perceptual_lightness_scaled_by

        def with_perceptual_luminance(value)
          channels = Sai.cache.fetch(self.class, :with_luminance, *channel_cache_key, value) do
            rgb = to_rgb(encoding_specification:)

            current_luminance = luminance
            return self if current_luminance.zero? || (current_luminance - value).abs < 0.001

            scale_factor = value / current_luminance

            nr, ng, nb = rgb.to_n_a.map { |channel| [channel * scale_factor, 1.0].min }
            scaled_rgb = RGB.intermediate(nr, ng, nb, encoding_specification:)

            if (scaled_rgb.luminance - value).abs > 0.01
              oklch = to_oklch(encoding_specification:)
              lightness_adjustment = value / current_luminance
              new_lightness = [oklch.l * lightness_adjustment, 1.0].min

              coerce(oklch.with_lightness(new_lightness)).to_n_a
            end
          end

          coerce(channels)
        end

        def with_perceptual_luminance_contracted_by(amount)
          with_perceptual_luminance(luminance * (1.0 - amount))
        end
        alias contract_perceptual_luminance with_perceptual_luminance_contracted_by

        def with_perceptual_luminance_decremented_by(amount = 0.1)
          with_perceptual_luminance([luminance - amount, 0.0].max)
        end
        alias decrement_perceptual_luminance with_perceptual_luminance_decremented_by

        def with_perceptual_luminance_incremented_by(amount = 0.1)
          with_perceptual_luminance([luminance + amount, 1.0].min)
        end
        alias increment_perceptual_luminance with_perceptual_luminance_incremented_by

        def with_perceptual_luminance_scaled_by(amount)
          with_perceptual_luminance(luminance * amount)
        end
        alias scale_perceptual_luminance with_perceptual_luminance_scaled_by

        def with_perceptual_saturation(value)
          oklch = to_oklch(encoding_specification:)
          new_saturation = [value, 1.0].min
          new_chroma = new_saturation * oklch.lightness * 2.0
          with_chroma(new_chroma)
        end

        def with_perceptual_saturation_contracted_by(amount)
          oklch = to_oklch(encoding_specification:)
          current_saturation = [oklch.chroma / (oklch.lightness * 2.0), 1.0].min
          new_saturation = current_saturation * (1.0 - amount)
          new_chroma = new_saturation * oklch.lightness * 2.0
          with_chroma(new_chroma)
        end
        alias contract_perceptual_saturation with_perceptual_saturation_contracted_by

        def with_perceptual_saturation_decremented_by(amount = 0.1)
          oklch = to_oklch(encoding_specification:)
          current_saturation = [oklch.chroma / (oklch.lightness * 2.0), 1.0].min
          new_saturation = [current_saturation - amount, 0.0].max
          new_chroma = new_saturation * oklch.lightness * 2.0
          with_chroma(new_chroma)
        end
        alias decrement_perceptual_saturation with_perceptual_saturation_decremented_by

        def with_perceptual_saturation_incremented_by(amount = 0.1)
          oklch = to_oklch(encoding_specification:)
          current_saturation = [oklch.chroma / (oklch.lightness * 2.0), 1.0].min
          new_saturation = [current_saturation + amount, 1.0].min
          new_chroma = new_saturation * oklch.lightness * 2.0
          with_chroma(new_chroma)
        end
        alias increment_perceptual_saturation with_perceptual_saturation_incremented_by

        def with_perceptual_saturation_scaled_by(amount)
          oklch = to_oklch(encoding_specification:)
          current_saturation = [oklch.chroma / (oklch.lightness * 2.0), 1.0].min
          new_saturation = current_saturation * amount
          new_chroma = [new_saturation * oklch.lightness * 2.0, 1.0].min
          with_chroma(new_chroma)
        end
        alias scale_perceptual_saturation with_perceptual_saturation_scaled_by

        def with_red(value)
          coerce(to_rgb(encoding_specification:).with_red(value))
        end

        def with_red_contracted_by(amount)
          coerce(to_rgb(encoding_specification:).with_red_contracted_by(amount))
        end
        alias contract_red with_red_contracted_by

        def with_red_decremented_by(amount = RGB.channels.red.differential_step)
          coerce(to_rgb(encoding_specification:).with_red_decremented_by(amount))
        end
        alias decrement_red with_red_decremented_by

        def with_red_incremented_by(amount = RGB.channels.red.differential_step)
          coerce(to_rgb(encoding_specification:).with_red_incremented_by(amount))
        end
        alias increment_red with_red_incremented_by

        def with_red_scaled_by(amount)
          coerce(to_rgb(encoding_specification:).with_red_scaled_by(amount))
        end
        alias scale_red with_red_scaled_by

        def with_saturation(value)
          coerce(to_hsl(encoding_specification:).with_saturation(value))
        end

        def with_saturation_contracted_by(amount)
          coerce(to_hsl(encoding_specification:).with_saturation_contracted_by(amount))
        end
        alias contract_saturation with_saturation_contracted_by

        def with_saturation_decremented_by(amount = HSL.channels.saturation.differential_step)
          coerce(to_hsl(encoding_specification:).with_saturation_decremented_by(amount))
        end
        alias decrement_saturation with_saturation_decremented_by

        def with_saturation_incremented_by(amount = HSL.channels.saturation.differential_step)
          coerce(to_hsl(encoding_specification:).with_saturation_incremented_by(amount))
        end
        alias increment_saturation with_saturation_incremented_by

        def with_saturation_scaled_by(amount)
          coerce(to_hsl(encoding_specification:).with_saturation_scaled_by(amount))
        end
        alias scale_saturation with_saturation_scaled_by

        def with_yellow(value)
          coerce(to_cmyk(encoding_specification:).with_yellow(value))
        end

        def with_yellow_contracted_by(amount)
          coerce(to_cmyk(encoding_specification:).with_yellow_contracted_by(amount))
        end
        alias contract_yellow with_yellow_contracted_by

        def with_yellow_decremented_by(amount = CMYK.channels.yellow.differential_step)
          coerce(to_cmyk(encoding_specification:).with_yellow_decremented_by(amount))
        end
        alias decrement_yellow with_yellow_decremented_by

        def with_yellow_incremented_by(amount = CMYK.channels.yellow.differential_step)
          coerce(to_cmyk(encoding_specification:).with_yellow_incremented_by(amount))
        end
        alias increment_yellow with_yellow_incremented_by

        def with_yellow_scaled_by(amount)
          coerce(to_cmyk(encoding_specification:).with_yellow_scaled_by(amount))
        end
        alias scale_yellow with_yellow_scaled_by

        private

        def initialize_copy(_source)
          super
          %i[
            @blue
            @brightness
            @chroma
            @correlated_color_temperature
            @cyan
            @green
            @hue
            @lightness
            @luminance
            @perceptual_brightness
            @perceptual_saturation
            @magenta
            @red
            @saturation
            @yellow
          ].each { |ivar| instance_variable_set(ivar, nil) }
        end
      end
    end
  end
end
