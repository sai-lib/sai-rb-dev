# frozen_string_literal: true

module Sai
  module Space
    module Core
      module Mixing
        class << self
          def circular_hue(source, mixer, weight: 50.0)
            h, s, l, a = Sai.cache.fetch(self, :circular_hue, source.identity, mixer.identity, weight) do
              sh, ss, sl = source.to_hsl.to_a
              mh, ms, ml = mixer.to_hsl.to_a

              weight /= PERCENTAGE_RANGE.end
              hue_max = Encoded::HSL.components.hue.boundary.max

              v1_degrees = sh * hue_max
              v2_degrees = mh * hue_max
              delta      = v2_degrees - v1_degrees

              if delta > (hue_max / 2.0)
                v1_degrees += hue_max
              elsif delta < -(hue_max / 2.0)
                v2_degrees + hue_max
              end

              v_degrees = (v1_degrees + (delta * weight)) % hue_max
              h         = v_degrees / hue_max
              s         = ss + ((ms - ss) * weight)
              l         = sl + ((ml - sl) * weight)

              opacity   = mix_opacity(source, mixer, weight)

              [h, s, l, opacity]
            end

            hsl = Encoded::HSL.from_intermediate(h, s, l).map_to_gamut
            result = source.coerce(hsl).with_opacity(a)
            result.encoded? ? result.map_to_gamut : result
          end

          def gamma_corrected(source, mixer, weight: 50.0)
            r, g, b, a = Sai.cache.fetch(self, :gamma_corrected, source.identity, mixer.identity, weight) do
              rgb_space = Sai.config.default_rgb_space

              source_rgb = source.to_rgb(rgb_space:).to_a
              mixer_rgb  = mixer.to_rgb(rgb_space:).to_a

              weight /= PERCENTAGE_RANGE.end

              source_linear_rgb = source_rgb.map { |component| rgb_space.to_linear(component) }
              mixer_linear_rgb  = mixer_rgb.map { |component| rgb_space.to_linear(component) }

              mixed = source_linear_rgb.zip(mixer_linear_rgb).map { |s, m| s + ((m - s) * weight) }

              r, g, b = mixed.map { |component| rgb_space.from_linear(component) }
              opacity = mix_opacity(source, mixer, weight)

              [r, g, b, opacity]
            end

            rgb = Sai.config.default_rgb_space.from_intermediate(r, g, b).map_to_gamut
            result = source.coerce(rgb).with_opacity(a)
            result.encoded? ? result.map_to_gamut : result
          end

          def linear(source, mixer, weight: 50.0)
            r, g, b, a = Sai.cache.fetch(self, :linear, source.identity, mixer.identity, weight) do
              rgb_space = Sai.config.default_rgb_space

              source_rgb = source.to_rgb(rgb_space:).to_a
              mixer_rgb  = mixer.to_rgb(rgb_space:).to_a

              weight /= PERCENTAGE_RANGE.end

              mixed = source_rgb.zip(mixer_rgb).map { |s, m| s + ((m - s) * weight) }

              [*mixed, mix_opacity(source, mixer, weight)]
            end

            rgb = Sai.config.default_rgb_space.from_intermediate(r, g, b).map_to_gamut
            result = source.coerce(rgb).with_opacity(a)
            result.encoded? ? result.map_to_gamut : result
          end

          def perceptually_uniform(source, mixer, weight: 50.0)
            l, a, b, opacity = Sai.cache.fetch(self, :perceptually_uniform, source.identity, mixer.identity, weight) do
              source_lab = source.to_lab_d50.to_a
              mixer_lab  = mixer.to_lab_d50.to_a

              weight /= PERCENTAGE_RANGE.end

              mixed = source_lab.zip(mixer_lab).map { |s, m| s + ((m - s) * weight) }

              [*mixed, mix_opacity(source, mixer, weight)]
            end

            lab = Perceptual::Lab::D50.from_intermediate(l, a, b)
            result = source.coerce(lab).with_opacity(opacity)
            result.encoded? ? result.map_to_gamut : result
          end

          def perceptually_weighted(source, mixer, weight: 50.0)
            components, opacity = Sai.cache.fetch(self, :perceptually_weighted, source.identity, mixer.identity,
                                                  weight) do
              formula  = Sai.config.default_distance_formula
              distance = formula.calculate(source, mixer)

              weight /= PERCENTAGE_RANGE.end
              adjusted_weight = weight

              if distance > formula::DEFAULT_VISUAL_THRESHOLD
                direction          = adjusted_weight <= 0.5 ? -1 : 1
                deviation          = (adjusted_weight - 0.5).abs
                adjusted_deviation = Math.sin(deviation * Math::PI / 2.0)
                adjusted_weight    = 0.5 + (direction * adjusted_deviation)
              end

              adjusted_weight *= PERCENTAGE_RANGE.end
              result  = perceptually_uniform(source, mixer, weight: adjusted_weight).to_a
              opacity = mix_opacity(source, mixer, weight)

              [result, opacity]
            end

            result = source.class.from_intermediate(*components)
            result.encoded? ? result.map_to_gamut.with_opacity(opacity) : result.with_opacity(opacity)
          end

          private

          def included(base)
            super

            base.include InstanceMethods
          end

          def mix_opacity(source, mixer, weight)
            source.opacity + ((mixer.opacity - source.opacity) * weight)
          end
        end

        module InstanceMethods
          def mix(other, **options)
            weight = options.fetch(:weight, 50.0)
            unless weight.is_a?(Numeric) && PERCENTAGE_RANGE.cover?(weight)
              raise TypeError, "`:weight` is invalid. Expected `Numeric` between 0.0 and 100.0, got #{weight.inspect}"
            end

            strategy = options.fetch(:strategy, Sai.config.default_mixing_strategy)

            case strategy
            when MixStrategy::PERCEPTUALLY_WEIGHTED then Mixing.perceptually_weighted(self, other, weight: weight)
            when MixStrategy::PERCEPTUALLY_UNIFORM  then Mixing.perceptually_uniform(self, other, weight: weight)
            when MixStrategy::CIRCULAR_HUE          then Mixing.circular_hue(self, other, weight: weight)
            when MixStrategy::GAMMA_CORRECTED       then Mixing.gamma_corrected(self, other, weight: weight)
            when MixStrategy::LINEAR                then Mixing.linear(self, other, weight: weight)
            else
              raise ArgumentError, '`:strategy` is invalid. Expected one of: ' \
                                   "#{MixStrategy::ALL.join(', ')}, got: #{strategy.inspect}"
            end
          end
        end
      end
    end
  end
end
