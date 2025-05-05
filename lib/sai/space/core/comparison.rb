# frozen_string_literal: true

module Sai
  module Space
    module Core
      module Comparison
        class << self
          private

          def included(base)
            super

            base.include InstanceMethods
          end
        end

        module InstanceMethods
          def ==(other)
            (other.is_a?(self.class) && other.identity == identity) ||
              (other.is_a?(Space) && coerce(other).identity == identity) ||
              (self.class.model === other && coerce(other).identity == identity)
          end

          def closest_match(*others, **options)
            formula = options.fetch(:formula, Sai.config.default_distance_formula)
            unless formula.is_a?(Formula::Distance)
              raise TypeError, "`:formula` is invalid. Expected `Sai::Formula::Distance`, got: #{formula.inspect}"
            end

            others = others.map { |other| coerce(other) }

            components = Sai.cache.fetch(self.class, :closest_match, identity, *others.flat_map(&:identity)) do
              calculations = others.map do |other|
                [other, formula.calculate(self, other, **options)]
              end

              closest = calculations.min_by(&:last).first

              coerce(closest).to_a
            end

            self.class.from_intermediate(*components, **options)
          end

          def distinguishable_from?(other, **options)
            !perceptually_equivalent?(other, **options)
          end

          def is_a?(mod)
            mod == Space ||
              (mod.respond_to?(:name) && mod.name.start_with?(Space.name) && self.class.name.start_with?(mod.name)) ||
              super
          end

          def perceptually_equivalent?(other, **options)
            other = coerce(other)

            formula = options.fetch(:formula, Sai.config.default_distance_formula)
            unless formula.is_a?(Formula::Distance)
              raise TypeError, "`:formula` is invalid. Expected `Sai::Formula::Distance`, got: #{formula.inspect}"
            end

            threshold = options.fetch(:threshold, formula::DEFAULT_VISUAL_THRESHOLD)
            formula.calculate(self, other, **options) <= threshold
          end

          def similarity_to(other, **options)
            formula = options.fetch(:formula, Sai.config.default_distance_formula)
            unless formula.is_a?(Formula::Distance)
              raise TypeError, "`:formula` is invalid. Expected `Sai::Formula::Distance`, got: #{formula.inspect}"
            end

            1.0 - (formula.calculate(self, other, **options) / 100.0)
          end
        end
      end
    end
  end
end
