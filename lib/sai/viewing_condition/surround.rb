# frozen_string_literal: true

module Sai
  class ViewingCondition
    class Surround
      include ManagedAttributes

      attribute :chromatic_induction_factor, Float, coerce: lambda(&:to_f), required: true

      attribute :factor, Float, coerce: lambda(&:to_f), required: true

      attribute :impact_factor, Float, coerce: lambda(&:to_f), required: true

      def initialize(**attributes)
        super
        freeze
      end
    end
  end
end
