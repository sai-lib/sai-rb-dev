# frozen_string_literal: true

module Sai
  class Space
    class Gamma
      include ManagedAttributes

      attribute :encoded_threshold, Float, coerce: lambda(&:to_f), depends_on: %i[strategy]

      attribute :exponent, Float, coerce: lambda(&:to_f), required: true

      attribute :linear_scale, Float, coerce: lambda(&:to_f), depends_on: %i[strategy]

      attribute :linear_threshold, Float, coerce: lambda(&:to_f), depends_on: %i[strategy]

      attribute :nonlinear_scale, Float, coerce: lambda(&:to_f), depends_on: %i[strategy]

      attribute :offset, Float, coerce: lambda(&:to_f), depends_on: %i[strategy]

      attribute :strategy, Symbol, required: true

      validates :encoded_threshold, :linear_scale, :linear_threshold, :nonlinear_scale, :offset,
                'is required when `:strategy` is `:transfer_function`' do |value|
        if strategy == Enum::ColorSpace::GammaStrategy::TRANSFER_FUNCTION
          !value.nil?
        else
          true
        end
      end

      validates :strategy, "must be one of #{Enum::ColorSpace::GammaStrategy.resolve_all.join(', ')}" do |strategy|
        Enum::ColorSpace::GammaStrategy.resolve_all.include?(strategy)
      end

      def initialize(**attributes)
        super
        freeze
      end

      def from_linear(value)
        case strategy
        when Enum::ColorSpace::GammaStrategy::LINEAR
          value**(1.0 / exponent)
        when Enum::ColorSpace::GammaStrategy::TRANSFER_FUNCTION
          if value <= linear_threshold
            value * linear_scale
          else
            (nonlinear_scale * (value**(1.0 / exponent))) - offset
          end
        end
      end

      def to_linear(value)
        case strategy
        when Enum::ColorSpace::GammaStrategy::LINEAR
          value**exponent
        when Enum::ColorSpace::GammaStrategy::TRANSFER_FUNCTION
          if value <= encoded_threshold
            value / linear_scale
          else
            ((value + offset) / nonlinear_scale)**exponent
          end
        end
      end
    end
  end
end
