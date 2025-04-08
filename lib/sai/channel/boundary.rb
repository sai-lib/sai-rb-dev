# frozen_string_literal: true

module Sai
  class Channel
    class Boundary
      attr_reader :center
      attr_reader :maximum
      alias max maximum

      attr_reader :minimum
      alias min minimum

      attr_reader :range
      attr_reader :width

      def initialize(range = nil)
        max = range&.end&.to_f || Float::INFINITY
        min = range&.begin&.to_f || -Float::INFINITY

        @center = range.nil? ? 0.0 : (max + min) / 2.0
        @maximum = max
        @minimum = min
        @range = min..max
        @width = max - min

        freeze
      end

      def bound?
        minimum.finite? && maximum.finite?
      end

      def unbound?
        !bound?
      end
    end
  end
end
