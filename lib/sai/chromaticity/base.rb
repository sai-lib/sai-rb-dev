# frozen_string_literal: true

module Sai
  module Chromaticity
    class Base
      include Core::Concurrency
      include Core::Identity

      class << self
        private

        def implements(model)
          unless model.is_a?(Model::Definition)
            raise TypeError, "`model` is invalid. Expected `Model::Definition`, got: #{model.inspect}"
          end

          model.implement(self)
        end
      end

      def initialize(*components)
        initialize_components!(*components, validate: false, normalized: true)
      end

      def ==(other)
        other.is_a?(Chromaticity) && coerce(other).identity == identity
      end

      def coerce(other)
        self.class.coerce(other)
      end

      def is_a?(mod)
        mod == Chromaticity || super
      end

      def to_array
        components.to_normalized
      end
      alias serialize to_array
      alias to_a      to_array

      def to_string
        "chromaticity_#{self.class.name.split('::').last.downcase}(#{components.to_string})"
      end
      alias inspect to_string
      alias to_s    to_string

      private

      def identity_attributes
        [self.class, components.identity].freeze
      end
    end
  end
end
