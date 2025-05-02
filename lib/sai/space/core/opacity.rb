# frozen_string_literal: true

module Sai
  module Space
    module Core
      module Opacity
        class << self
          private

          def included(base)
            super

            base.include InstanceMethods
          end
        end

        module InstanceMethods
          attr_reader :opacity
          alias alpha opacity

          def with_opacity(opacity)
            unless opacity.is_a?(Numeric)
              raise TypeError, "`opacity` is invalid. Expected `Numeric`, got `#{opacity.class}`"
            end

            unless PERCENTAGE_RANGE.cover?(opacity)
              raise ArgumentError,
                    "`opacity` is invalid. Expected a value between 0.0 and 100.0, got `#{opacity}`"
            end

            duped = dup
            duped.instance_variable_set(:@opacity, opacity.to_f)
            duped
          end
          alias with_alpha with_opacity

          def with_opacity_contracted_by(amount)
            with_opacity((opacity / amount.to_f).clamp(PERCENTAGE_RANGE))
          end
          alias contract_alpha           with_opacity_contracted_by
          alias contract_opacity         with_opacity_contracted_by
          alias with_alpha_contracted_by with_opacity_contracted_by

          def with_opacity_decremented_by(amount)
            with_opacity((opacity - amount.to_f).clamp(PERCENTAGE_RANGE))
          end
          alias decrement_alpha           with_opacity_decremented_by
          alias decrement_opacity         with_opacity_decremented_by
          alias with_alpha_decremented_by with_opacity_decremented_by

          def with_opacity_flattened(background = [0, 0, 0], **options)
            rgb_space     = options.fetch(:rgb_space, options.fetch(:space, Sai.config.default_rgb_space))
            no            = opacity / PERCENTAGE_RANGE.end
            nr, ng, nb    = rgb_space.coerce(self).map_to_gamut.to_a
            nrb, ngb, nbb = rgb_space.coerce(background).map_to_gamut.to_a

            ro = (nr * no) + (nrb * (1.0 - no))
            go = (ng * no) + (ngb * (1.0 - no))
            bo = (nb * no) + (nbb * (1.0 - no))

            coerce(rgb_space.from_intermediate(ro, go, bo).map_to_gamut)
          end
          alias flatten_alpha        with_opacity_flattened
          alias flatten_opacity      with_opacity_flattened
          alias with_alpha_flattened with_opacity_flattened

          def with_opacity_incremented_by(amount)
            with_opacity((opacity + amount.to_f).clamp(PERCENTAGE_RANGE))
          end
          alias increment_alpha           with_opacity_incremented_by
          alias increment_opacity         with_opacity_incremented_by
          alias with_alpha_incremented_by with_opacity_incremented_by

          def with_opacity_scaled_by(amount)
            with_opacity((opacity * amount.to_f).clamp(PERCENTAGE_RANGE))
          end
          alias scale_alpha          with_opacity_scaled_by
          alias scale_opacity        with_opacity_scaled_by
          alias with_alpha_scaled_by with_opacity_scaled_by

          private

          def initialize_opacity!(**options)
            opacity = options.fetch(:opacity, PERCENTAGE_RANGE.end).to_f

            unless opacity.is_a?(Numeric)
              raise TypeError, "`:opacity` is invalid. Expected `Numeric`, got #{opacity.inspect}"
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
end
