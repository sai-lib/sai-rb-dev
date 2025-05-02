# frozen_string_literal: true

module Sai
  module Space
    module Core
      module Harmony
        class << self
          private

          def included(base)
            super

            base.include InstanceMethods
          end
        end

        module InstanceMethods
          def analogous(count = 3, angle = 30)
            concurrent_instance_variable_fetch(
              :@analogous,
              begin
                half = (count - 1) / 2.0
                (0...count).map do |i|
                  offset = (i - half) * angle
                  i.zero? ? self : with_hue_incremented_by(offset)
                end
              end,
            )
          end

          def complementary
            concurrent_instance_variable_fetch(
              :@complementary,
              with_hue_incremented_by(180),
            )
          end

          def double_complementary(angle = 30)
            concurrent_instance_variable_fetch(
              :@double_complementary,
              [
                self,
                with_hue_incremented_by(angle),
                with_hue_incremented_by(180),
                with_hue_incremented_by(180 + angle),
              ],
            )
          end

          def monochromatic(count = 5)
            concurrent_instance_variable_fetch(
              :@monochromatic,
              begin
                lightness_values = (0...count).map { |i| (i + 1.0) / (count + 1.0) }
                lightness_values.map { |l| with_perceptual_lightness(l) }
              end,
            )
          end

          def shades(count = 5)
            concurrent_instance_variable_fetch(
              :@shades,
              begin
                lightness_values = (0...count).map { |i| (i + 1.0) / (count + 1.0) }
                _, c, h = to_oklch.to_a
                lightness_values.map { |new_l| coerce(Perceptual::Oklch.from_intermediate(new_l, c, h)) }
              end,
            )
          end

          def split_complementary(angle = 30)
            concurrent_instance_variable_fetch(
              :@split_complementary,
              [
                self,
                with_hue_incremented_by(180 - angle),
                with_hue_incremented_by(180 + angle),
              ],
            )
          end

          def tetradic
            concurrent_instance_variable_fetch(
              :@tetradic,
              [
                self,
                with_hue_incremented_by(90),
                with_hue_incremented_by(180),
                with_hue_incremented_by(270),
              ],
            )
          end
          alias square tetradic

          def triadic
            concurrent_instance_variable_fetch(
              :@triadic,
              [
                self,
                with_hue_incremented_by(120),
                with_hue_incremented_by(240),
              ],
            )
          end
        end
      end
    end
  end
end
