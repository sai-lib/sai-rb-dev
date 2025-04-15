# frozen_string_literal: true

module Sai
  class Model
    module Core
      module Mixing
        class << self
          def circular_hue(source, mixer, weight, **options)
            channels = Sai.cache.fetch(
              Mixing, source.symbol, mixer.symbol, *source.channel_cache_key, *mixer.channel_cache_key, options
            ) do
              hsl1 = source.to_hsl(**options)
              hsl2 = mixer.to_hsl(**options)

              h1, s1, l1 = hsl1.to_n_a
              h2, s2, l2 = hsl2.to_n_a

              weight /= PERCENTAGE_RANGE.end

              hue_max = HSL.channels.hue.boundary.max

              v1_deg = h1 * 360
              v2_deg = h2 * 360

              diff = v2_deg - v1_deg

              if diff > 180
                v1_deg += 360
              elsif diff < -180
                v2_deg += 360
              end

              v_deg = (v1_deg + ((v2_deg - v1_deg) * weight)) % hue_max
              h = v_deg / hue_max

              s = s1 + ((s2 - s1) * weight)
              l = l1 + ((l2 - l1) * weight)

              opacity = mix_opacity(source, mixer, weight * PERCENTAGE_RANGE.end)
              mixed_hsl = HSL.intermediate(h, s, l, **options, opacity: opacity)
              source.coerce(mixed_hsl, **options).to_n_a
            end

            source.class.intermediate(*channels, **options)
          end

          def gamma_corrected(source, mixer, weight, **options)
            channels = Sai.cache.fetch(
              Mixing, source.symbol, mixer.symbol, *source.channel_cache_key, *mixer.channel_cache_key, options
            ) do
              rgb1 = source.to_rgb(**options)
              rgb2 = mixer.to_rgb(**options)

              r1, g1, b1 = rgb1.to_n_a
              r2, g2, b2 = rgb2.to_n_a

              weight /= PERCENTAGE_RANGE.end

              space = options.fetch(:color_space, rgb1.encoding_specification.color_space)
              gamma = space.gamma

              r1_lin = gamma.to_linear(r1)
              g1_lin = gamma.to_linear(g1)
              b1_lin = gamma.to_linear(b1)

              r2_lin = gamma.to_linear(r2)
              g2_lin = gamma.to_linear(g2)
              b2_lin = gamma.to_linear(b2)

              r_lin = r1_lin + ((r2_lin - r1_lin) * weight)
              g_lin = g1_lin + ((g2_lin - g1_lin) * weight)
              b_lin = b1_lin + ((b2_lin - b1_lin) * weight)

              r = gamma.from_linear(r_lin)
              g = gamma.from_linear(g_lin)
              b = gamma.from_linear(b_lin)

              opacity = mix_opacity(source, mixer, weight * PERCENTAGE_RANGE.end)
              mixed_rgb = RGB.intermediate(r, g, b, opacity: opacity)
              source.coerce(mixed_rgb, **options).to_n_a
            end

            source.class.intermediate(*channels, **options)
          end

          def gamut_aware(source, mixer, weight, **options)
            channels = Sai.cache.fetch(
              Mixing, source.symbol, mixer.symbol, *source.channel_cache_key, *mixer.channel_cache_key, options
            ) do
              mixed_color = perceptually_uniform(source, mixer, weight, **options)
              encoding_specification = source.encoding_specification(**options)
              strategy = options.fetch(:gamut_mapping_strategy, Sai.config.default_gamut_mapping_strategy)
              mapped_color = encoding_specification.map_to_gamut(mixed_color, strategy: strategy)
              mapped_color.to_n_a
            end

            source.class.intermediate(*channels, **options)
          end

          def linear(source, mixer, weight, **options)
            channels = Sai.cache.fetch(
              Mixing, source.symbol, mixer.symbol, *source.channel_cache_key, *mixer.channel_cache_key, options
            ) do
              rgb1 = source.to_rgb(**options)
              rgb2 = mixer.to_rgb(**options)

              r1, g1, b1 = rgb1.to_n_a
              r2, g2, b2 = rgb2.to_n_a

              weight /= PERCENTAGE_RANGE.end

              r = r1 + ((r2 - r1) * weight)
              g = g1 + ((g2 - g1) * weight)
              b = b1 + ((b2 - b1) * weight)

              opacity = mix_opacity(source, mixer, weight * PERCENTAGE_RANGE.end)
              mixed_rgb = RGB.intermediate(r, g, b, opacity: opacity)
              source.coerce(mixed_rgb, **options).to_n_a
            end

            source.class.intermediate(*channels, **options)
          end

          def perceptually_uniform(source, mixer, weight, **options)
            channels = Sai.cache.fetch(
              Mixing, source.symbol, mixer.symbol, *source.channel_cache_key, *mixer.channel_cache_key, options
            ) do
              lab1 = source.to_lab(**options)
              lab2 = mixer.to_lab(**options)

              l1, a1, b1 = lab1.to_n_a
              l2, a2, b2 = lab2.to_n_a

              weight /= PERCENTAGE_RANGE.end

              l = l1 + ((l2 - l1) * weight)
              a = a1 + ((a2 - a1) * weight)
              b = b1 + ((b2 - b1) * weight)

              opacity = mix_opacity(source, mixer, weight * PERCENTAGE_RANGE.end)
              mixed_lab = Lab.intermediate(l, a, b, opacity: opacity)
              result = source.coerce(mixed_lab, **options)

              encoding_specification = source.encoding_specification(**options)
              unless encoding_specification.in_gamut?(result)
                strategy = options.fetch(:gamut_mapping_strategy, Sai.config.default_gamut_mapping_strategy)
                result = encoding_specification.map_to_gamut(result, strategy: strategy)
              end

              result.to_n_a
            end

            source.class.intermediate(*channels, **options)
          end

          def perceptually_weighted(source, mixer, weight, **options)
            channels = Sai.cache.fetch(
              Mixing, source.symbol, mixer.symbol, *source.channel_cache_key, *mixer.channel_cache_key, options
            ) do
              formula = Enum.resolve(options.fetch(:formula, Sai.config.default_distance_formula))
              distance = formula.calculate(source, mixer, **options)

              norm_weight = weight / PERCENTAGE_RANGE.end

              if distance > formula::DEFAULT_VISUAL_THRESHOLD
                direction = norm_weight <= 0.5 ? -1 : 1

                deviation = (norm_weight - 0.5).abs

                adjusted_deviation = Math.sin(deviation * Math::PI / 2)

                norm_weight = 0.5 + (direction * adjusted_deviation)
              end

              adjusted_weight = norm_weight * PERCENTAGE_RANGE.end
              result = perceptually_uniform(source, mixer, adjusted_weight, **options)
              result.to_n_a
            end

            source.class.intermediate(*channels, **options)
          end

          private

          def mix_opacity(source, mixer, weight)
            weight /= PERCENTAGE_RANGE.end
            source.opacity + ((mixer.opacity - source.opacity) * weight)
          end
        end

        def mix(other, **options)
          other = coerce(other)

          weight = options.fetch(:weight, 50.0)
          unless weight.is_a?(Numeric) && PERCENTAGE_RANGE.cover?(weight)
            raise ArgumentError, "`:weight` is invalid. Expected value between 0.0 and 100.0, got: #{weight.inspect}"
          end

          strategy = Enum.resolve(options.fetch(:strategy, Sai.config.default_mix_strategy))

          case strategy
          when Enum::MixStrategy::GAMUT_AWARE
            Mixing.gamut_aware(self, other, weight, **options)
          when Enum::MixStrategy::PERCEPTUALLY_WEIGHTED
            Mixing.perceptually_weighted(self, other, weight, **options)
          when Enum::MixStrategy::PERCEPTUALLY_UNIFORM
            Mixing.perceptually_uniform(self, other, weight, **options)
          when Enum::MixStrategy::CIRCULAR_HUE
            Mixing.circular_hue(self, other, weight, **options)
          when Enum::MixStrategy::LINEAR
            Mixing.linear(self, other, weight, **options)
          when Enum::MixStrategy::GAMMA_CORRECTED
            Mixing.gamma_corrected(self, other, weight, **options)
          else
            raise ArgumentError, '`:strategy` is invalid. Expected one of ' \
                                 "#{Enum::MixStrategy.resolve_all.join(', ')}, got: #{strategy.inspect}"
          end
        end
      end
    end
  end
end
