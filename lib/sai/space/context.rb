# frozen_string_literal: true

module Sai
  module Space
    class Context
      include Sai::Core::Concurrency
      include Sai::Core::Identity
      include Sai::Core::ManagedAttributes

      attribute :chromatic_adaptation_transform, ChromaticAdaptationTransform,
                default: -> { Sai.config.default_chromatic_adaptation_transform }, required: true
      alias_attribute :cat, :chromatic_adaptation_transform

      attribute :cone_transform, ChromaticAdaptationTransform,
                default: -> { Sai.config.default_cone_transform }, required: true

      attribute :illuminant, Illuminant, default: -> { Sai.config.default_illuminant }, required: true

      attribute :observer, Observer, default: -> { Sai.config.default_observer }, required: true

      def initialize(**attributes)
        initialize_attributes!(**attributes)
      end

      def ==(other)
        other.is_a?(self.class) && other.identity == identity
      end

      def chromaticity
        concurrent_instance_variable_fetch(:@chromaticity, Chromaticity.from_xyz(white_point))
      end

      def correlated_color_temperature
        concurrent_instance_variable_fetch(
          :@correlated_color_temperature,
          Formula::CorrelatedColorTemperature.recommended_method(source_type: illuminant.type).calculate(chromaticity),
        )
      end
      alias cct         correlated_color_temperature
      alias temperature correlated_color_temperature

      def name
        concurrent_instance_variable_fetch(
          :@name,
          begin
            vf_str = (observer.visual_field % 1).zero? ? "#{observer.visual_field.round}°" : "#{observer.visual_field}°"
            "#{illuminant.name}/#{vf_str}"
          end,
        )
      end

      def to_hash
        {
          chromatic_adaptation_transform: chromatic_adaptation_transform,
          cone_transform: cone_transform,
          illuminant: illuminant,
          observer: observer,
        }
      end
      alias to_h to_hash

      def white_point
        concurrent_instance_variable_fetch(
          :@white_point,
          observer.color_matching_function
                  .spectral_power_distribution_to_tristimulus(illuminant.spectral_power_distribution),
        )
      end

      def with(**options)
        new_cat = process_attribute!(
          :chromatic_adaptation_transform,
          options.fetch(
            :chromatic_adaptation_transform,
            options.fetch(:cat, chromatic_adaptation_transform),
          ),
        )

        new_cone_transform = process_attribute!(:cone_transform, options.fetch(:cone_transform, cone_transform))
        new_illuminant     = process_attribute!(:illuminant, options.fetch(:illuminant, illuminant))
        new_observer       = process_attribute!(:observer, options.fetch(:observer, observer))

        duped = dup
        duped.instance_variable_set(:@chromatic_adaptation_transform, new_cat)
        duped.instance_variable_set(:@cone_transform, new_cone_transform)
        duped.instance_variable_set(:@illuminant, new_illuminant)
        duped.instance_variable_set(:@observer, new_observer)

        duped
      end

      def with_chromatic_adaptation_transform(new_cat)
        return self if new_cat == chromatic_adaptation_transform

        with(chromatic_adaptation_transform: new_cat)
      end
      alias with_cat with_chromatic_adaptation_transform

      def with_cone_transform(new_cone_transform)
        return self if new_cone_transform == cone_transform

        with(cone_transform: new_cone_transform)
      end

      def with_illuminant(new_illuminant)
        return self if new_illuminant == illuminant

        with(illuminant: new_illuminant)
      end

      def with_observer(new_observer)
        return self if new_observer == observer

        with(observer: new_observer)
      end

      private

      def identity_attributes
        [
          self.class,
          chromatic_adaptation_transform.identity,
          cone_transform.identity,
          observer.identity,
          illuminant.identity,
        ].freeze
      end

      def initialize_copy(source)
        super

        %i[
          @chromaticity
          @correlated_color_temperature
          @identity
          @name
          @white_point
        ].each { |ivar| instance_variable_set(ivar, nil) }

        self
      end
    end
  end
end
