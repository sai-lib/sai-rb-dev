# frozen_string_literal: true

module Sai
  class Model
    module Core
      module Comparison
        def ==(other)
          (other.is_a?(self.class) && other.to_array == to_array) ||
            (other.is_a?(Array) && other == to_n_a)
        end

        def closest_match(*others, **options)
          formula = Enum.resolve(options.fetch(:formula, Sai.config.default_distance_formula))
          unless formula.name.start_with?(Sai::Formula::Distance.name)
            raise TypeError, "`:formula` is invalid. Expected `Sai::Formula::Distance`, got: #{formula.inspect}"
          end

          cache_key = [
            self.class,
            :closest_match,
            *channel_cache_key,
            *others.map(&:channel_cache_key).flatten,
            options,
          ]

          channels = Sai.cache.fetch(*cache_key) do
            closest = others.map do |other|
              [other, formula.calculate(self, coerce(other), **options)]
            end.min_by(&:last).first

            coerce(closest, **options).to_n_a
          end

          self.class.from_fraction(*channels, **options)
        end

        def complementary(**options)
          formula = Enum.resolve(options.fetch(:formula, Sai.config.default_distance_formula))
          unless formula.name.start_with?(Sai::Formula::Distance.name)
            raise TypeError, "`:formula` is invalid. Expected `Sai::Formula::Distance`, got: #{formula.inspect}"
          end

          channels = Sai.cache.fetch(self.class, :complementary, *channel_cache_key, options) do
            best_complement = to_hsl(**options)
            best_complement = best_complement.with_hue(hsl.h + 0.5)
            max_distance = -Float::INFINITY

            hue_offsets = [-0.05, 0, 0.05]
            saturation_lightness_offsets = [-0.1, 0, 0.1]

            hue_offsets.product(saturation_lightness_offsets,
                                saturation_lightness_offsets) do |h_offset, s_offset, l_offset|
              h = (hsl.h + h_offset)
              s = (hsl.s + s_offset).clamp(FRACTION_RANGE)
              l = (hsl.l + l_offset).clamp(FRACTION_RANGE)

              candidate = hsl.with_hue(h).with_saturation(s).with_lightness(l)
              distance = formula.calculate(self, coerce(candidate), **options)

              if distance > max_distance
                max_distance = distance
                best_complement = candidate
              end
            end

            coerce(best_complement, **options).to_n_a
          end

          self.class.from_fraction(*channels, **options)
        end

        def distinguishable_from?(other, **options)
          !perceptually_equivalent?(other, **options)
        end

        def perceptually_equivalent?(other, **options)
          other = coerce(other)

          formula = Enum.resolve(options.fetch(:formula, Sai.config.default_distance_formula))
          unless formula.name.start_with?(Sai::Formula::Distance.name)
            raise TypeError, "`:formula` is invalid. Expected `Sai::Formula::Distance`, got: #{formula.inspect}"
          end

          threshold = options.fetch(:threshold, formula::DEFAULT_VISUAL_THRESHOLD)
          formula.calculate(self, other, **options) <= threshold
        end
      end
    end
  end
end
