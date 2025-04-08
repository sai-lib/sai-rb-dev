# frozen_string_literal: true

module Sai
  class Matrix
    class Vector
      attr_reader :elements
      attr_reader :orientation

      class << self
        def column(*elements)
          elements = elements.flatten
          new(elements, orientation: :column)
        end

        def row(*elements)
          elements = elements.flatten
          new(elements, orientation: :row)
        end
      end

      def initialize(elements, orientation: :row)
        @elements = elements.map { |element| element.is_a?(Model) ? element.to_a : element }.flatten.freeze
        @orientation = orientation
        freeze
      end

      def ==(other)
        other.is_a?(Vector) &&
          other.orientation == orientation &&
          other.elements == elements
      end

      def [](index)
        @elements[index]
      end

      def each(&)
        return to_enum(:each) unless block_given?

        @elements.each(&)
        self
      end

      def map(&)
        self.class.new(@elements.map(&), orientation: orientation)
      end

      def map_with_index(&)
        self.class.new(@elements.map.with_index(&), orientation: orientation)
      end

      def size
        @elements.size
      end
      alias length size
      alias count size

      def to_a
        case orientation
        when :row then [@elements.dup]
        when :column then @elements.zip
        end
      end
      alias to_array to_a
      alias to_ary to_a
    end
  end
end
