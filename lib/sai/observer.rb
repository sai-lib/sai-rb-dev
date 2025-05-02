# frozen_string_literal: true

module Sai
  class Observer
    autoload :FairchildModifier, 'sai/observer/fairchild_modifier'

    extend  Core::DefferedConstant
    include Core::Identity
    include Core::ManagedAttributes

    class << self
      def load(path, **options)
        new(**Sai.data_store.load(path, **options).transform_keys(&:to_sym))
      end
    end

    deffered_constant(:CIE_1931_2_DEGREE) do
      load('observer/cie_1931_2_degree.yml', symbolize_names: true)
    end
    alias_deffered_constant :CIE_1931, :CIE_1931_2_DEGREE

    deffered_constant(:CIE_1964_10_DEGREE) do
      load('observer/cie_1964_10_degree.yml', symbolize_names: true)
    end
    alias_deffered_constant :CIE_1964, :CIE_1964_10_DEGREE

    deffered_constant(:CIE_2006_2_DEGREE) do
      load('observer/cie_2006_2_degree.yml', symbolize_names: true)
    end

    deffered_constant(:CIE_2006_10_DEGREE) do
      load('observer/cie_2006_10_degree.yml', symbolize_names: true)
    end

    deffered_constant(:JUDD_2_DEGREE) do
      load('observer/cie_1931_judd_2_degree.yml', symbolize_names: true)
    end
    alias_deffered_constant :JUDD, :JUDD_2_DEGREE

    deffered_constant(:JUDD_VOSS_2_DEGREE) do
      load('observer/cie_1931_judd_voss_2_degree.yml', symbolize_names: true)
    end
    alias_deffered_constant :JUDD_VOSS, :JUDD_VOSS_2_DEGREE

    deffered_constant(:STILES_BURCH_2_DEGREE) do
      load('observer/stiles_burch_2_degree.yml', symbolize_names: true)
    end

    deffered_constant(:STILES_BURCH_10_DEGREE) do
      load('observer/stiles_burch_10_degree.yml', symbolize_names: true)
    end

    deffered_constant(:STOCKMAN_SHARPE_2_DEGREE) do
      load('observer/stockman_sharpe_2_degree.yml', symbolize_names: true)
    end

    deffered_constant(:STOCKMAN_SHARPE_10_DEGREE) do
      load('observer/stockman_sharpe_10_degree.yml', symbolize_names: true)
    end

    attribute :age, Integer

    attribute :chromaticity_coordinates, Spectral::ChromaticityCoordinates,
              coerce: lambda { |v|
                v.is_a?(Spectral::ChromaticityCoordinates) ? v : Spectral::ChromaticityCoordinates.coerce(v)
              },
              default: -> { calculate_chromaticity_coordinates },
              depends_on: %i[color_matching_function],
              required: true

    attribute :color_matching_function, Spectral::ColorMatchingFunction,
              coerce: lambda { |v|
                v.is_a?(Spectral::ColorMatchingFunction) ? v : Spectral::ColorMatchingFunction.coerce(v)
              },
              required: true
    alias_attribute :cmf, :color_matching_function

    attribute :cone_fundamentals, Spectral::ConeFundamentals,
              coerce: ->(v) { v.is_a?(Spectral::ConeFundamentals) ? v : Spectral::ConeFundamentals.coerce(v) },
              default: -> { calculate_cone_fundamentals },
              depends_on: %i[color_matching_function],
              required: true

    attribute :cone_transform, ChromaticAdaptationTransform,
              default: -> { Sai.config.default_cone_transform },
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
        @visual_field
        @age
        @modifications
        @color_matching_function
        @cone_fundamentals
        @chromaticity_coordinates
        @cone_transform
      ]
    end

    def with_cone_transform(new_cone_transform)
      new_cone_transform = process_attribute!(:cone_transform, new_cone_transform)

      duped = dup

      duped.instance_variable_set(:@cone_transform, new_cone_transform)
      duped.instance_variable_set(:@modifications, modifications.merge(cone_transform: new_cone_transform.name))
      duped.instance_variable_set(:@cone_fundamentals, duped.send(:calculate_cone_fundamentals))
      duped.instance_variable_set(:@name, duped.send(:modified_name))

      duped
    end

    def with_physiological_factors(age: self.age, visual_field: self.visual_field, **options)
      return self if age == self.age && visual_field == self.visual_field

      new_age          = process_attribute!(:age, age)
      new_visual_field = process_attribute!(:visual_field, visual_field)
      modifications    = new_age == self.age ? self.modifications : self.modifications.merge(age: new_age)
      modifications    = modifications.merge(visual_field: new_visual_field) if new_visual_field != self.visual_field
      new_attributes   = FairchildModifier.transform(
        self,
        visual_field: new_visual_field,
        age: new_age,
        **options,
      )

      duped = dup

      duped.instance_variable_set(:@age, new_age)
      duped.instance_variable_set(:@visual_field, new_visual_field)
      duped.instance_variable_set(:@modifications, modifications)
      new_attributes.each_pair { |attribute, value| duped.instance_variable_set(:"@#{attribute}", value) }
      duped.instance_variable_set(:@name, duped.send(:modified_name))

      duped
    end

    private

    def calculate_chromaticity_coordinates
      data = color_matching_function.transform_values { |xyz| Chromaticity::XY.from_xyz(xyz) }
      Spectral::ChromaticityCoordinates.coerce(data)
    end

    def calculate_cone_fundamentals
      data = color_matching_function.transform_values { |xyz| cone_transform.xyz_to_lms(xyz) }
      Spectral::ConeFundamentals.coerce(data)
    end

    def identity_attributes
      [
        self.class,
        name,
        age,
        visual_field,
        modifications,
        color_matching_function.identity,
        cone_fundamentals.identity,
        chromaticity_coordinates.identity,
        cone_transform.identity,
      ].freeze
    end

    def modified_name
      return name if modifications.empty?

      visual_field_string = (visual_field % 1).zero? ? "#{visual_field.round}°" : "#{visual_field}°"
      modified_name = name.gsub('Standard', 'Modified').gsub(/\d+°/, visual_field_string).gsub(/\((.*?)\)/, '').strip
      "#{modified_name} (#{modifications.map { |k, v| "#{k}: #{v}" }.join(', ')})"
    end
  end
end
