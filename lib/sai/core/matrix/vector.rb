# frozen_string_literal: true

module Sai
  module Core
    class Matrix
      class Vector
        include Enumerable

        attr_reader :elements
        attr_reader :orientation

        class << self
          def column(*elements)
            new(*elements.flatten, orientation: :column)
          end

          def row(*elements)
            new(*elements.flatten, orientation: :row)
          end
        end

        def initialize(*elements, orientation: :row)
          @elements    = elements.flatten
          @orientation = orientation
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
        alias count  size
        alias length size

        def to_array
          case orientation
          when :row then [@elements.dup]
          when :column then @elements.zip
          end
        end
        alias to_a   to_array
        alias to_ary to_array
      end
    end
  end
end

Sai.events.emit_load(Sai::Core::Matrix::Vector)
