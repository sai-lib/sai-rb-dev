# frozen_string_literal: true

module Sai
  class Observer
    autoload :ChromaticityCoordinates, 'sai/observer/chromaticity_coordinates'
    autoload :ColorMatchingFunction,   'sai/observer/color_matching_function'
    autoload :ConeFundamentals,        'sai/observer/cone_fundamentals'
    autoload :FairchildModifier,       'sai/observer/fairchild_modifier'

    include ManagedAttributes

    attribute :age, Integer

    attribute :chromaticity_coordinates, ChromaticityCoordinates,
              coerce: ->(v) { v.is_a?(ChromaticityCoordinates) || v.nil? ? v : ChromaticityCoordinates.new(v) },
              default: -> { calculate_chromaticity_coordinates },
              depends_on: %i[color_matching_function]

    attribute :color_matching_function, ColorMatchingFunction,
              coerce: ->(v) { v.is_a?(ColorMatchingFunction) ? v : ColorMatchingFunction.new(v) },
              required: true
    alias_attribute :cmf, :color_matching_function

    attribute :cone_fundamentals, ConeFundamentals,
              coerce: ->(v) { v.is_a?(ConeFundamentals) || v.nil? ? v : ConeFundamentals.new(v) },
              default: -> { calculate_cone_fundamentals },
              depends_on: %i[color_matching_function cone_transform]

    attribute :cone_transform, ChromaticAdaptationTransform,
              default: -> { Sai.config.default_cone_fundamentals_transform },
              required: true

    attribute :modifications, Hash, default: EMPTY_HASH, required: true

    attribute :name, String, required: true

    attribute :visual_field, Numeric, coerce: lambda(&:to_f), required: true

    validates :age, 'must be between 1 and 80' do |age|
      (1..80).cover?(age)
    end

    validates :visual_field, 'must be between 2.0 and 10.0' do |visual_field|
      (2.0..10.0).cover?(visual_field)
    end

    def self.load(path, **options)
      new(**Sai.data_store.load(path, **options).transform_keys(&:to_sym))
    end

    def initialize(**attributes)
      super

      @name = modified_name.freeze
      @modifications.freeze

      freeze
    end

    def spectral_power_distribution_to_xyz(spectral_power_distribution)
      x, y, z = Sai.cache.fetch(Observer, :spectral_power_distribution_to_xyz, hash,
                                spectral_power_distribution.hash) do
        unless spectral_power_distribution.is_a?(Illuminant::SpectralPowerDistribution)
          raise TypeError, '`spectral_power_distribution` is invalid. ' \
                           'Expected `Sai::Illuminant::SpectralPowerDistribution`, ' \
                           "got: #{spectral_power_distribution.inspect}"
        end

        channels = [0.0, 0.0, 0.0]
        step = color_matching_function.step

        color_matching_function.each do |wavelength, xyz|
          spd_value = spectral_power_distribution.at(wavelength)
          next if spd_value.nil?

          xyz_array = xyz.to_a

          channels = channels.map.with_index do |channel, index|
            channel + (spd_value * xyz_array[index] * step)
          end
        end

        if channels[1].positive?
          scale_factor = 1.0 / channels[1]
          channels[0] *= scale_factor
          channels[1] = 1.0
          channels[2] *= scale_factor
          channels
        else
          [0.0, 0.0, 0.0]
        end
      end
      Model::XYZ.new(x, y, z)
    end
    alias spd_to_xyz spectral_power_distribution_to_xyz

    def with_cone_transform(new_cone_transform)
      new_cone_transform = process_attribute!(:cone_transform, new_cone_transform)

      dup.tap do |duped|
        duped.instance_variable_set(:@cone_transform, new_cone_transform)
        duped.instance_variable_set(
          :@modifications,
          modifications.merge(cone_transform: new_cone_transform.name).freeze,
        )
        duped.instance_variable_set(:@cone_fundamentals, duped.send(:calculate_cone_fundamentals).freeze)
        duped.instance_variable_set(:@name, duped.send(:modified_name).freeze)
      end.freeze
    end

    def with_physiological_factors(age: self.age, visual_field: self.visual_field, **options)
      return self if age == self.age && visual_field == self.visual_field

      new_age = process_attribute!(:age, age)
      new_visual_field = process_attribute!(:visual_field, visual_field)
      modifications = new_age == self.age ? self.modifications : self.modifications.merge(age: new_age)
      modifications = modifications.merge(visual_field: new_visual_field) if new_visual_field != self.visual_field
      new_attributes = FairchildModifier.transform(self, visual_field: new_visual_field, age: new_age, **options)

      dup.tap do |duped|
        duped.instance_variable_set(:@age, new_age)
        duped.instance_variable_set(:@visual_field, new_visual_field)
        duped.instance_variable_set(:@modifications, modifications.freeze)
        new_attributes.each_pair { |attribute, value| duped.instance_variable_set(:"@#{attribute}", value) }
        duped.instance_variable_set(:@name, duped.send(:modified_name).freeze)
      end.freeze
    end

    private

    def calculate_chromaticity_coordinates
      wavelengths = color_matching_function.transform_values do |xyz|
        Chromaticity.from_xyz(xyz)
      end

      ChromaticityCoordinates.new(wavelengths)
    end

    def calculate_cone_fundamentals
      wavelengths = color_matching_function.each_with_object({}) do |(wavelength, xyz), range|
        vector = cone_transform.class.column_vector(xyz)
        lms = cone_transform * vector
        range[wavelength] = Model::LMS.new(*lms.to_a.flatten)
      end

      ConeFundamentals.new(wavelengths)
    end

    def modified_name
      return name if modifications.empty?

      modified_name = name.gsub('Standard', 'Modified').gsub(/\((.*?)\)/, '').strip
      "#{modified_name} (#{modifications.map { |k, v| "#{k}: #{v}" }.join(', ')})"
    end
  end
end
