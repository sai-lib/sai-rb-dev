# frozen_string_literal: true

module Sai
  class Model
    module Core
      module Opacity
        attr_reader :opacity
        alias alpha opacity

        def with_opacity(opacity)
          unless opacity.is_a?(Numeric)
            raise TypeError,
                  "`opacity` is invalid. Expected `Numeric`, got #{opacity.inspect}`"
          end
          unless PERCENTAGE_RANGE.cover?(opacity)
            raise ArgumentError,
                  "`opacity` is invalid. Expected `Numeric` between 0.0 and 100.0, got #{opacity.inspect}"
          end

          dup.tap { |duped| duped.instance_variable_set(:@opacity, opacity.to_f) }
        end
        alias with_alpha with_opacity

        def with_opacity_contracted_by(amount)
          with_opacity((opacity / amount.to_f))
        end
        alias contract_alpha           with_opacity_contracted_by
        alias contract_opacity         with_opacity_contracted_by
        alias with_alpha_contracted_by with_opacity_contracted_by

        def with_opacity_decremented_by(amount)
          with_opacity((opacity - amount.to_f))
        end
        alias decrement_alpha           with_opacity_decremented_by
        alias decrement_opacity         with_opacity_decremented_by
        alias with_alpha_decremented_by with_opacity_decremented_by

        def with_opacity_flattened
          return self unless opacity < PERCENTAGE_RANGE.end

          new_channels = self.class.channels.symbols.map do |symbol|
            original = instance_variable_get(:"@#{symbol}")
            original * opacity
          end

          self.class.new(*new_channels)
        end
        alias flatten_alpha        with_opacity_flattened
        alias flatten_opacity      with_opacity_flattened
        alias with_alpha_flattened with_opacity_flattened

        def with_opacity_incremented_by(amount)
          with_opacity((opacity + amount.to_f))
        end
        alias increment_alpha           with_opacity_incremented_by
        alias increment_opacity         with_opacity_incremented_by
        alias with_alpha_incremented_by with_opacity_incremented_by

        def with_opacity_scaled_by(amount)
          with_opacity((opacity * amount.to_f))
        end
        alias scale_alpha          with_opacity_scaled_by
        alias scale_opacity        with_opacity_scaled_by
        alias with_alpha_scaled_by with_opacity_scaled_by

        private

        def initialize_opacity(**options)
          opacity = options.fetch(:opacity, options.fetch(:alpha, PERCENTAGE_RANGE.end))

          unless opacity.is_a?(Numeric)
            raise TypeError,
                  "`:opacity` is invalid. Expected `Numeric`, got #{opacity.inspect}"
          end
          unless PERCENTAGE_RANGE.cover?(opacity)
            raise ArgumentError,
                  "`:opacity` is invalid. Expected `Numeric` between 0.0 and 100.0, got #{opacity.inspect}"
          end

          @opacity = opacity.to_f
        end
      end
    end
  end
end
