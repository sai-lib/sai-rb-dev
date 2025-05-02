# frozen_string_literal: true

module Sai
  class Illuminant
    autoload :Normalization,             'sai/illuminant/normalization'
    autoload :Type,                      'sai/illuminant/type'

    extend  Core::DefferedConstant
    include Core::Identity
    include Core::ManagedAttributes

    class << self
      def load(path, **options)
        new(**Sai.data_store.load(path, **options).transform_keys(&:to_sym))
      end
    end

    deffered_constant(:A)        { load('illuminant/a.yml', symbolize_names: true) }
    deffered_constant(:B)        { load('illuminant/b.yml', symbolize_names: true) }
    deffered_constant(:C)        { load('illuminant/c.yml', symbolize_names: true) }
    deffered_constant(:D50)      { load('illuminant/d50.yml', symbolize_names: true) }
    deffered_constant(:D55)      { load('illuminant/d55.yml', symbolize_names: true) }
    deffered_constant(:D60)      { load('illuminant/d60.yml', symbolize_names: true) }
    deffered_constant(:D65)      { load('illuminant/d65.yml', symbolize_names: true) }
    deffered_constant(:D75)      { load('illuminant/d75.yml', symbolize_names: true) }
    deffered_constant(:E)        { load('illuminant/e.yml', symbolize_names: true) }
    deffered_constant(:FL1)      { load('illuminant/fl1.yml', symbolize_names: true) }
    deffered_constant(:FL2)      { load('illuminant/fl2.yml', symbolize_names: true) }
    deffered_constant(:FL3)      { load('illuminant/fl3.yml', symbolize_names: true) }
    deffered_constant(:FL3_1)    { load('illuminant/fl3_1.yml', symbolize_names: true) }
    deffered_constant(:FL3_2)    { load('illuminant/fl3_2.yml', symbolize_names: true) }
    deffered_constant(:FL3_3)    { load('illuminant/fl3_3.yml', symbolize_names: true) }
    deffered_constant(:FL3_4)    { load('illuminant/fl3_4.yml', symbolize_names: true) }
    deffered_constant(:FL3_5)    { load('illuminant/fl3_5.yml', symbolize_names: true) }
    deffered_constant(:FL3_6)    { load('illuminant/fl3_6.yml', symbolize_names: true) }
    deffered_constant(:FL3_7)    { load('illuminant/fl3_7.yml', symbolize_names: true) }
    deffered_constant(:FL3_8)    { load('illuminant/fl3_8.yml', symbolize_names: true) }
    deffered_constant(:FL3_9)    { load('illuminant/fl3_9.yml', symbolize_names: true) }
    deffered_constant(:FL3_10)   { load('illuminant/fl3_10.yml', symbolize_names: true) }
    deffered_constant(:FL3_11)   { load('illuminant/fl3_11.yml', symbolize_names: true) }
    deffered_constant(:FL3_12)   { load('illuminant/fl3_12.yml', symbolize_names: true) }
    deffered_constant(:FL3_13)   { load('illuminant/fl3_13.yml', symbolize_names: true) }
    deffered_constant(:FL3_14)   { load('illuminant/fl3_14.yml', symbolize_names: true) }
    deffered_constant(:FL3_15)   { load('illuminant/fl3_15.yml', symbolize_names: true) }
    deffered_constant(:FL4)      { load('illuminant/fl4.yml', symbolize_names: true) }
    deffered_constant(:FL5)      { load('illuminant/fl5.yml', symbolize_names: true) }
    deffered_constant(:FL6)      { load('illuminant/fl6.yml', symbolize_names: true) }
    deffered_constant(:FL7)      { load('illuminant/fl7.yml', symbolize_names: true) }
    deffered_constant(:FL8)      { load('illuminant/fl8.yml', symbolize_names: true) }
    deffered_constant(:FL9)      { load('illuminant/fl9.yml', symbolize_names: true) }
    deffered_constant(:FL10)     { load('illuminant/fl10.yml', symbolize_names: true) }
    deffered_constant(:FL11)     { load('illuminant/fl11.yml', symbolize_names: true) }
    deffered_constant(:FL12)     { load('illuminant/fl12.yml', symbolize_names: true) }
    deffered_constant(:HP1)      { load('illuminant/hp1.yml', symbolize_names: true) }
    deffered_constant(:HP2)      { load('illuminant/hp2.yml', symbolize_names: true) }
    deffered_constant(:HP3)      { load('illuminant/hp3.yml', symbolize_names: true) }
    deffered_constant(:HP4)      { load('illuminant/hp4.yml', symbolize_names: true) }
    deffered_constant(:HP5)      { load('illuminant/hp5.yml', symbolize_names: true) }
    deffered_constant(:ID50)     { load('illuminant/id50.yml', symbolize_names: true) }
    deffered_constant(:ID65)     { load('illuminant/id65.yml', symbolize_names: true) }
    deffered_constant(:LED_B1)   { load('illuminant/led_b1.yml', symbolize_names: true) }
    deffered_constant(:LED_B2)   { load('illuminant/led_b2.yml', symbolize_names: true) }
    deffered_constant(:LED_B3)   { load('illuminant/led_b3.yml', symbolize_names: true) }
    deffered_constant(:LED_B4)   { load('illuminant/led_b4.yml', symbolize_names: true) }
    deffered_constant(:LED_B5)   { load('illuminant/led_b5.yml', symbolize_names: true) }
    deffered_constant(:LED_BH1)  { load('illuminant/led_bh1.yml', symbolize_names: true) }
    deffered_constant(:LED_RGB1) { load('illuminant/led_rgb1.yml', symbolize_names: true) }
    deffered_constant(:LED_V1)   { load('illuminant/led_v1.yml', symbolize_names: true) }
    deffered_constant(:LED_V2)   { load('illuminant/led_v2.yml', symbolize_names: true) }

    attribute :modifications, Hash, default: EMPTY_HASH, required: true

    attribute :name, String, required: true

    attribute :native_normalization, Symbol, required: true

    attribute :normalization, Symbol,
              default: -> { native_normalization },
              depends_on: %i[native_normalization],
              required: true

    attribute :spectral_power_distribution, Spectral::PowerDistribution,
              coerce: ->(v) { v.is_a?(Spectral::PowerDistribution) ? v : Spectral::PowerDistribution.new(v) },
              required: true
    alias_attribute :spd, :spectral_power_distribution

    attribute :type, Symbol, required: true

    validates :native_normalization, :normalization,
              "must be one of #{Normalization::ALL.join(', ')}" do |normalization|
      Normalization::ALL.include?(normalization)
    end

    validates :type, "must be one of #{Type::ALL.join(', ')}" do |type|
      Type::ALL.include?(type)
    end

    def initialize(**attributes)
      initialize_attributes!(**attributes)

      @name = modified_name
    end

    def ==(other)
      other.is_a?(self.class) && other.identity == identity
    end

    def pretty_print_instance_variables
      %i[
        @name
        @type
        @modifications
        @native_normalization
        @normalization
        @spectral_power_distribution
      ]
    end

    def with_normalization(new_normalization)
      new_normalization = process_attribute!(:normalization, new_normalization)
      return self if normalization == new_normalization

      duped = dup

      duped.instance_variable_set(:@normalization, new_normalization)
      duped.instance_variable_set(:@modifications, modifications.merge(normalization: new_normalization))
      duped.instance_variable_set(:@name, duped.send(:modified_name))
      duped.instance_variable_set(
        :@spectral_power_distribution,
        duped.send(:normalize_spectral_power_distribution),
      )

      duped
    end

    private

    def identity_attributes
      [
        self.class,
        name,
        type,
        modifications,
        normalization,
        spectral_power_distribution.identity,
      ].freeze
    end

    def modified_name
      return name if modifications.empty?

      modified_name = name.gsub('Modified', '').gsub(/\((.*?)\)/, '').strip
      "#{modified_name} Modified (#{modifications.map { |k, v| "#{k}: #{v}" }.join(', ')})"
    end

    def normalize_spectral_power_distribution
      scaling_factor = case normalization
                       when Normalization::STANDARD_LUMINANCE, Normalization::CIE_LUMINANCE
                         current_luminance = white_point.y
                         return FRACTION_RANGE.end if current_luminance.zero?

                         target_luminance = case normalization
                                            when Normalization::STANDARD_LUMINANCE
                                              FRACTION_RANGE.end
                                            when Normalization::CIE_LUMINANCE
                                              PERCENTAGE_RANGE.end
                                            end

                         target_luminance / current_luminance
                       when Normalization::UNITY_PEAK
                         max_value = spectral_power_distribution.max_value
                         return FRACTION_RANGE.end if max_value.zero?

                         FRACTION_RANGE.end / max_value
                       when Normalization::UNITY_ENERGY
                         current_area = spectral_power_distribution.sum_values * spectral_power_distribution.step
                         return FRACTION_RANGE.end if current_area.zero?

                         FRACTION_RANGE.end / current_area
                       else FRACTION_RANGE.end
                       end
      return spectral_power_distribution.dup.freeze if scaling_factor == 1

      spd = spectral_power_distribution.transform_values { |value| value * scaling_factor }.freeze
      Spectral::PowerDistribution.new(spd)
    end
  end
end
