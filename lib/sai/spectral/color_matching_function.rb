# frozen_string_literal: true

module Sai
  module Spectral
    class ColorMatchingFunction < Table
      with_responses Tristimulus

      coerce_responses_with do |data|
        data.transform_values do |value|
          value.is_a?(Tristimulus) ? value : Tristimulus.new(*value)
        end
      end

      def spectral_power_distribution_to_tristimulus(spectral_power_distribution)
        unless spectral_power_distribution.is_a?(PowerDistribution)
          raise TypeError, '`spectral_power_distribution` is invalid. Expected a `Sai::Spectral::PowerDistribution, ' \
                           "got: #{spectral_power_distribution.inspect}"
        end

        cache_key = [
          self.class,
          :spectral_power_distribution_to_tristimulus,
          *[self, spectral_power_distribution].map(&:identity),
        ]

        x, y, z = Sai.cache.fetch(*cache_key) do
          components = [0.0, 0.0, 0.0]

          each_pair do |wavelength, response|
            spd_value = spectral_power_distribution.at(wavelength)
            next if spd_value.nil?

            xyz_array = response.to_array

            components = components.map.with_index do |component, index|
              component + (spd_value * xyz_array[index] * step)
            end
          end

          if components[1].positive?
            scale_factor = 1.0 / components[1]
            components[0] *= scale_factor
            components[1] = 1.0
            components[2] *= scale_factor
            components
          else
            [0.0, 0.0, 0.0]
          end
        end

        Tristimulus.new(x, y, z)
      end
      alias spd_to_tristimulus spectral_power_distribution_to_tristimulus
      alias spd_to_xyz         spectral_power_distribution_to_tristimulus
    end
  end
end
