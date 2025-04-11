# frozen_string_literal: true

module Sai
  class ViewingCondition
    autoload :Surround, 'sai/viewing_condition/surround'

    include ManagedAttributes

    attribute :adapting_luminance, Numeric, required: true

    attribute :application, String

    attribute :background_luminance, Numeric, required: true

    computed_attribute :chromatic_background_induction_factor, depends_on: %i[luminance_ratio] do
      0.725 * ((1.0 / luminance_ratio)**0.2)
    end
    alias_attribute :background_induction_factor, :chromatic_background_induction_factor

    computed_attribute :degree_of_adaptation, depends_on: %i[adapting_luminance surround] do
      surround.factor * (1 - ((1.0 / 3.6) * Math.exp((-adapting_luminance - 42) / 92.0)))
    end

    attribute :illuminant, Illuminant, required: true

    computed_attribute :luminance_ratio, depends_on: %i[background_luminance illuminant] do
      background_luminance / illuminant.white_point.y
    end

    attribute :name, String, required: true

    attribute :surround, Surround,
              coerce: ->(v) { v.is_a?(Surround) ? v : Surround.new(**v) },
              default: -> { Sai::Enum::ViewingCondition::SurroundType::AVERAGE },
              required: true

    computed_attribute :surround_effect, depends_on: %i[luminance_ratio] do
      1.48 + Math.sqrt(luminance_ratio)
    end

    def self.load(path, **options)
      data = Sai.data_store.load(path, **options).transform_keys(&:to_sym)

      illuminant_id = data.delete(:illuminant_id)
      surround_id = data.delete(:surround_id)

      new(
        illuminant: Enum::Illuminant.resolve(illuminant_id&.to_sym),
        surround: Enum::ViewingCondition::SurroundType.resolve(surround_id&.to_sym),
        **data,
      )
    end

    def initialize(**attributes)
      super
      freeze
    end

    def with_illuminant(new_illuminant)
      new_illuminant = process_attribute!(:illuminant, new_illuminant)
      return self if new_illuminant == illuminant

      dup.tap do |duped|
        duped.instance_variable_set(:@illuminant, new_illuminant)
        duped.send(:recompute_computed_attributes!)
      end.freeze
    end

    def with_surround(new_surround)
      new_surround = process_attribute!(:surround, new_surround)
      return self if new_surround == surround

      dup.tap do |duped|
        duped.instance_variable_set(:@surround, new_surround)
        duped.send(:recompute_computed_attributes!)
      end.freeze
    end
  end
end
