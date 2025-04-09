# frozen_string_literal: true

module Sai
  class Observer
    module FairchildModifier
      DEFAULTS = {
        age_yellowing_factor: 0.01,
        blue_range: 50.0,
        blue_threshold: 450,
        field_size_factor: 0.005,
        macular_density_decay_rate: 0.3,
        macular_peak: 460,
        macular_spread: 1000,
        rod_contribution_factor: 0.03,
        rod_peak: 500,
        rod_spread: 5000,
        s_cone_field_factor: 0.05,
        s_cone_peak: 440,
        s_cone_spread: 2000,
      }.freeze

      class << self
        def transform(observer, visual_field:, age: nil, **options)
          result = Sai.cache.fetch(FairchildModifier, :transform, observer.hash, visual_field, age) do
            options = DEFAULTS.merge(options)
            # Generate the new color_matching_function
            cmf = observer.color_matching_function.each_with_object({}) do |(wavelength, xyz), result|
              vector = observer.cone_transform.class.column_vector(xyz)
              lms = observer.cone_transform * vector

              lens_factor = if age.nil?
                              1.0 - ((visual_field - observer.visual_field) * options[:field_size_factor])
                            else
                              delta = age - observer.age
                              weight = [options[:blue_threshold] - wavelength, 0].max / options[:blue_range]

                              1.0 - (delta * options[:age_yellowing_factor] * weight)
                            end

              macular_density_decay_rate = options[:macular_density_decay_rate]
              original_density = Math.exp(-macular_density_decay_rate * observer.visual_field.to_f)
              new_density = Math.exp(-macular_density_decay_rate * visual_field.to_f)

              wavelength_factor = Math.exp(-((wavelength - options[:macular_peak])**2) / options[:macular_spread].to_f)

              macular_factor = 1.0 - ((original_density - new_density) * wavelength_factor)

              rod_effect = if observer.visual_field > visual_field
                             delta = (visual_field - observer.visual_field) * options[:rod_contribution_factor]
                             delta * Math.exp(-((wavelength - options[:rod_peak])**2) / options[:rod_spread].to_f)
                           else
                             0.0
                           end

              s_cone_effect = if wavelength < options[:blue_threshold] && observer.visual_field != visual_field
                                s_cone_field_factor = options[:s_cone_field_factor]
                                s_factor = (visual_field > observer.visual_field ? 1 : -1) * s_cone_field_factor
                                s_factor *
                                  Math.exp(-((wavelength - options[:s_cone_peak])**2) / options[:s_cone_spread].to_f)
                              else
                                0.0
                              end
              receptor_factor = 1.0 + rod_effect + s_cone_effect

              adjusted_lms = lms.to_a.flatten.map.with_index do |value, index|
                case index
                when 0, 1 then value * lens_factor * receptor_factor
                when 2 then value * macular_factor * lens_factor * receptor_factor
                end
              end

              adjusted_lms_vector = observer.cone_transform.class.column_vector(adjusted_lms)
              adjusted_xyz = observer.cone_transform.inverse * adjusted_lms_vector
              result[wavelength] = adjusted_xyz.to_a.flatten
            end

            # Normalize the color_matching_function
            cmf = begin
              y_original = observer.color_matching_function.sum_values { |xyz| xyz.y.normalized.to_f }
              y_new = cmf.values.sum { |xyz| xyz[1].to_f }
              factor = y_new.zero? ? 1.0 : y_original / y_new

              cmf.transform_values { |xyz| xyz.map { |channel| channel * factor } }
            end

            # Generate the new cone fundamentals
            cone_fundamentals = cmf.transform_values do |xyz|
              lms = observer.cone_transform * observer.cone_transform.class.column_vector(xyz)
              lms.to_a.flatten
            end

            # Generate the new chromaticity coordinates
            chromaticity_coordinates = cmf.transform_values { |xyz| Chromaticity.from_xyz(xyz).to_n_a }

            {
              color_matching_function: cmf,
              cone_fundamentals: cone_fundamentals,
              chromaticity_coordinates: chromaticity_coordinates,
            }
          end

          {
            color_matching_function: ColorMatchingFunction.new(result[:color_matching_function]),
            cone_fundamentals: ConeFundamentals.new(result[:cone_fundamentals]),
            chromaticity_coordinates: ChromaticityCoordinates.new(result[:chromaticity_coordinates]),
          }
        end
      end
    end
  end
end
