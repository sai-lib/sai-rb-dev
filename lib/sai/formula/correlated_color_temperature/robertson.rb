# frozen_string_literal: true

module Sai
  module Formula
    module CorrelatedColorTemperature
      module Robertson
        ISOTEMPERATURE_LINES = [
          [10, 0.18006, 0.26352, -0.24341],
          [20, 0.18066, 0.26589, -0.25479],
          [30, 0.18133, 0.26846, -0.26876],
          [40, 0.18208, 0.27119, -0.28539],
          [50, 0.18293, 0.27407, -0.30470],
          [60, 0.18388, 0.27709, -0.32675],
          [70, 0.18494, 0.28021, -0.35156],
          [80, 0.18611, 0.28342, -0.37915],
          [90, 0.18740, 0.28668, -0.40955],
          [100, 0.18880, 0.28997, -0.44278],
          [125, 0.19271, 0.29812, -0.53213],
          [150, 0.19685, 0.30605, -0.62798],
          [175, 0.20116, 0.31368, -0.73237],
          [200, 0.20559, 0.32099, -0.84743],
          [225, 0.21012, 0.32800, -0.97550],
          [250, 0.21472, 0.33474, -1.11805],
          [275, 0.21935, 0.34122, -1.27743],
          [300, 0.22398, 0.34746, -1.45681],
          [325, 0.22859, 0.35349, -1.66028],
          [350, 0.23316, 0.35932, -1.89351],
          [375, 0.23766, 0.36496, -2.16292],
          [400, 0.24205, 0.37044, -2.47597],
          [425, 0.24633, 0.37577, -2.84361],
          [450, 0.25047, 0.38096, -3.28060],
          [475, 0.25448, 0.38601, -3.80678],
          [500, 0.25836, 0.39094, -4.44942],
          [525, 0.26208, 0.39575, -5.23406],
          [550, 0.26566, 0.40045, -6.18686],
          [575, 0.26909, 0.40503, -7.35488],
          [600, 0.27238, 0.40952, -8.81572],
        ].freeze
        private_constant :ISOTEMPERATURE_LINES

        VALID_RANGE = 1667..10_000
        private_constant :VALID_RANGE

        class << self
          def calculate(chromaticity)
            unless chromaticity.is_a?(Chromaticity)
              raise TypeError, "`chromaticity` is invalid. Expected `Sai::Chromaticity`, got: #{chromaticity.inspect}"
            end

            Sai.cache.fetch(Robertson, :calculate, *chromaticity.channel_cache_key) do
              x, y = chromaticity.to_a

              min_distance = Float::INFINITY
              closest_line_index = nil

              ISOTEMPERATURE_LINES.each_with_index do |line, i|
                _, x_t, y_t, slope = line

                dx = x - x_t
                dy = y - y_t

                distance = (dy - (slope * dx)).abs / Math.sqrt(1 + (slope**2))

                if distance < min_distance
                  min_distance = distance
                  closest_line_index = i
                end
              end

              return nil unless closest_line_index

              mireds = ISOTEMPERATURE_LINES[closest_line_index][0]

              cct = (1_000_000 / mireds).round

              cct
            end
          end

          def within_valid_range?(cct)
            VALID_RANGE.include?(cct)
          end
        end
      end
    end
  end
end
