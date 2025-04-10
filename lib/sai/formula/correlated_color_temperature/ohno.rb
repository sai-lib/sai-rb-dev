# frozen_string_literal: true

module Sai
  module Formula
    module CorrelatedColorTemperature
      module Ohno
        C1 = 3.741832e-16
        private_constant :C1

        C2 = 1.4388e-2
        private_constant :C2

        REFINEMENT_ITERATIONS = 5
        private_constant :REFINEMENT_ITERATIONS

        TEMPERATURE_RANGE = 1000..25_000
        private_constant :TEMPERATURE_RANGE

        TEMPERATURE_STEP = 100
        private_constant :TEMPERATURE_STEP

        VALID_RANGE = 1000..100_000
        private_constant :VALID_RANGE

        class << self
          def calculate(chromaticity)
            unless chromaticity.is_a?(Chromaticity)
              raise TypeError, "`chromaticity` is invalid. Expected `Sai::Chromaticity`, got: #{chromaticity.inspect}"
            end

            Sai.cache.fetch(Ohno, :calculate, *chromaticity.channel_cache_key) do
              x, y = chromaticity.to_a

              up, vp = begin
                denominator = (-2.0 * x) + (12.0 * y) + 3.0
                if denominator.zero?
                  [0.0, 0.0]
                else
                  up = 4.0 * x / denominator
                  vp = 9.0 * y / denominator

                  [up, vp]
                end
              end

              min_distance = Float::INFINITY
              best_cct = nil

              temp_range = TEMPERATURE_RANGE.step(TEMPERATURE_STEP)
              temp_range.each do |temp|
                temp_up, temp_vp = planckian_uv_coordinates(temp)

                distance = Math.sqrt(((up - temp_up)**2) + ((vp - temp_vp)**2))

                if distance < min_distance
                  min_distance = distance
                  best_cct = temp
                end
              end

              if best_cct
                low_temp = best_cct - TEMPERATURE_STEP
                high_temp = best_cct + TEMPERATURE_STEP

                REFINEMENT_ITERATIONS.times do
                  mid_temp = (low_temp + high_temp) / 2.0

                  mid_up, mid_vp = planckian_uv_coordinates(mid_temp)
                  mid_distance = Math.sqrt(((up - mid_up)**2) + ((vp - mid_vp)**2))

                  low_up, low_vp = planckian_uv_coordinates(low_temp)
                  low_distance = Math.sqrt(((up - low_up)**2) + ((vp - low_vp)**2))

                  high_up, high_vp = planckian_uv_coordinates(high_temp)
                  high_distance = Math.sqrt(((up - high_up)**2) + ((vp - high_vp)**2))

                  if mid_distance < min_distance
                    min_distance = mid_distance
                    best_cct = mid_temp
                  end

                  if low_distance < high_distance
                    high_temp = mid_temp
                  else
                    low_temp = mid_temp
                  end
                end
              end

              best_cct&.round
            end
          end

          def within_valid_range?(cct)
            VALID_RANGE.include?(cct)
          end

          private

          def planckian_uv_coordinates(temperature)
            Sai.cache.fetch(Ohno, :planckian_uv_coordinates, temperature) do
              if temperature <= 4000
                a0 = 0.179910
                a1 = -0.000991
                a2 = -0.000001
                a3 = 0.000000
                b0 = 0.436320
                b1 = -0.000823
                b2 = 0.000000
              else
                a0 = 0.183660
                a1 = -0.004603
                a2 = 0.000050
                a3 = 0.000000
                b0 = 0.384100
                b1 = 0.009468
                b2 = -0.000087
              end
              b3 = 0.000000

              t_recip = 1000.0 / temperature

              up = a0 + (a1 * t_recip) + (a2 * (t_recip**2)) + (a3 * (t_recip**3))
              vp = b0 + (b1 * t_recip) + (b2 * (t_recip**2)) + (b3 * (t_recip**3))

              [up, vp]
            end
          end
        end
      end
    end
  end
end
