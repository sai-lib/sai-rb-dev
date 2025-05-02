# frozen_string_literal: true

module Sai
  module Spectral
    class ChromaticityCoordinates < Table
      with_responses Chromaticity

      coerce_responses_with do |data|
        data.transform_values do |value|
          value.is_a?(Chromaticity) ? value : Chromaticity.xy(*value)
        end
      end

      def contains_chromaticity?(chromaticity)
        unless chromaticity.is_a?(Chromaticity)
          raise TypeError, "`chromaticity` is invalid. Expected `Sai::Chromaticity`, got `#{chromaticity.inspect}`"
        end

        Sai.cache.fetch(self.class, :contains_chromaticity?, identity, *chromaticity.identity) do
          x, y = chromaticity.to_xy.to_a
          violet_point = responses.values.first
          red_point = responses.values.last

          closed_locus = responses.values.map(&:to_a) + [red_point, violet_point].map(&:to_a)
          inside = false

          j = closed_locus.size - 1
          (0..closed_locus.size).each do |i|
            xi, yi = closed_locus[i]
            xj, yj = closed_locus[j]

            inside = ((yi > y) != (yj > y)) && ((x < ((xj - xi) * (y - yi) / (yj - yi)) + xi))

            j = i
          end

          inside
        end
      end
    end
  end
end
