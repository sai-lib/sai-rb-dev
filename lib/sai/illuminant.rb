# frozen_string_literal: true

module Sai
  class Illuminant
    autoload :SpectralPowerDistribution, 'sai/illuminant/spectral_power_distribution'

    include ManagedAttributes

    attribute :chromaticity, Chromaticity,
              coerce: ->(v) { v.is_a?(Chromaticity) ? v : Chromaticity.new(*v) },
              default: -> { Chromaticity.from_xyz(white_point) },
              depends_on: %i[white_point],
              required: true

    attribute :correlated_color_temperature, Numeric,
              default: lambda {
                Formula::CorrelatedColorTemperature.recommended_method(source_type: type, high_precision: true)
                                                   .calculate(chromaticity)
              },
              depends_on: %i[chromaticity type],
              required: true
    alias_attribute :cct, :correlated_color_temperature

    attribute :modifications, Hash, default: EMPTY_HASH, required: true

    attribute :name, String, required: true

    attribute :native_observer, Observer, required: true

    attribute :native_normalization, Symbol, required: true

    attribute :normalization, Symbol,
              default: -> { native_normalization },
              depends_on: %i[native_normalization],
              required: true

    attribute :observer, Observer, default: -> { native_observer }, depends_on: %i[native_observer], required: true

    attribute :spectral_power_distribution, SpectralPowerDistribution,
              coerce: ->(v) { v.is_a?(SpectralPowerDistribution) ? v : SpectralPowerDistribution.new(v) },
              required: true
    alias_attribute :spd, :spectral_power_distribution

    attribute :type, Symbol, required: true

    attribute :white_point, Model::XYZ,
              coerce: ->(v) { v.is_a?(Model::XYZ) ? v : Model::XYZ.new(*v) },
              default: -> { observer.spectral_power_distribution_to_xyz(spectral_power_distribution) },
              depends_on: %i[observer spectral_power_distribution],
              required: true

    validates :native_normalization, :normalization,
              "must be one of #{Enum::Illuminant::Normalization.resolve_all.join(', ')}" do |normalization|
      Enum::Illuminant::Normalization.resolve_all.include?(normalization)
    end

    validates :type, "must be one of #{Enum::Illuminant::Type.resolve_all.join(', ')}" do |type|
      Enum::Illuminant::Type.resolve_all.include?(type)
    end

    def self.load(path, **options)
      data = Sai.data_store.load(path, **options).transform_keys(&:to_sym)

      native_observer_id = data.delete(:native_observer_id)
      native_observer = Enum::Observer.resolve(native_observer_id&.to_sym)

      native_normalization_id = data.delete(:native_normalization_id)
      native_normalization = Enum::Illuminant::Normalization.resolve(native_normalization_id&.to_sym)

      new(native_observer:, native_normalization:, **data)
    end

    def initialize(**attributes)
      super

      @name = modified_name.freeze
      @modifications.freeze

      freeze
    end

    def with_normalization(new_normalization)
      new_normalization = process_attribute!(:normalization, new_normalization)
      return self if normalization == new_normalization

      dup.tap do |duped|
        duped.instance_variable_set(:@normalization, new_normalization)
        duped.instance_variable_set(:@modifications, modifications.merge(normalization: new_normalization).freeze)
        duped.instance_variable_set(:@name, duped.send(:modified_name).freeze)
        duped.instance_variable_set(:@spectral_power_distribution, duped.send(:normalize_spectral_power_distribution))
      end.freeze
    end

    def with_observer(new_observer)
      new_observer = process_attribute!(:observer, new_observer)
      return self if observer == new_observer

      dup.tap do |duped|
        duped.instance_variable_set(:@observer, new_observer)
        duped.instance_variable_set(:@modifications, modifications.merge(observer: new_observer.name).freeze)
        duped.instance_variable_set(:@name, duped.send(:modified_name).freeze)

        new_white_point = new_observer.spectral_power_distribution_to_xyz(duped.spectral_power_distribution)
        duped.instance_variable_set(:@white_point, new_white_point)
        duped.instance_variable_set(:@chromaticity, Chromaticity.from_xyz(new_white_point))

        duped.instance_variable_set(
          :@correlated_color_temperature,
          Formula::CorrelatedColorTemperature.recommended_method(source_type: duped.type, high_precision: true)
                                             .calculate(duped.chromaticity),
        )
      end.freeze
    end

    private

    def modified_name
      return name if modifications.empty?

      modified_name = name.gsub('Modified', '').gsub(/\((.*?)\)/, '').strip
      "#{modified_name} Modified (#{modifications.map { |k, v| "#{k}: #{v}" }.join(', ')})"
    end

    def normalize_spectral_power_distribution
      scaling_factor = case normalization
                       when Enum::Illuminant::Normalization::STANDARD_LUMINANCE,
                            Enum::Illuminant::Normalization::CIE_LUMINANCE
                         current_luminance = white_point.y
                         return FRACTION_RANGE.end if current_luminance.zero?

                         target_luminance = case normalization
                                            when Enum::Illuminant::Normalization::STANDARD_LUMINANCE
                                              FRACTION_RANGE.end
                                            when Enum::Illuminant::Normalization::CIE_LUMINANCE
                                              PERCENTAGE_RANGE.end
                                            end

                         target_luminance / current_luminance
                       when Enum::Illuminant::Normalization::UNITY_PEAK
                         max_value = spectral_power_distribution.max_value
                         return FRACTION_RANGE.end if max_value.zero?

                         FRACTION_RANGE.end / max_value
                       when Enum::Illuminant::Normalization::UNITY_ENERGY
                         current_area = spectral_power_distribution.sum_values * spectral_power_distribution.step
                         return FRACTION_RANGE.end if current_area.zero?

                         FRACTION_RANGE.end / current_area
                       else FRACTION_RANGE.end
                       end
      return spectral_power_distribution.dup.freeze if scaling_factor == 1

      spectral_power_distribution.transform_values { |value| value * scaling_factor }.freeze
    end
  end
end
