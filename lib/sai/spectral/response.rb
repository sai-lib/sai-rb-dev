# frozen_string_literal: true

module Sai
  module Spectral
    class Response
      include Core::Concurrency
      include Core::Identity

      attr_reader :source_white

      class << self
        def identifier
          concurrent_instance_variable_fetch(
            :@identifier,
            Core::Inflection.snake_case(name.split('::').last).to_sym,
          )
        end

        private

        def identified_as(identifier)
          mutex.synchronize { @identifier = identifier }
        end

        def implements(model)
          unless model.is_a?(Model::Definition)
            raise TypeError, "`model` is invalid. Expected `Model::Definition`, got: #{model.inspect}"
          end

          model.implement(self)
        end
      end

      def initialize(*components, **options)
        initialize_components!(*components, **options)
      end

      def ==(other)
        other.is_a?(self.class) && other.identity == identity
      end

      def coerce(other)
        self.class.coerce(other)
      end

      def identifier
        concurrent_instance_variable_fetch(:@identifier, self.class.identifier)
      end

      def serialize
        [*to_array, identifier]
      end

      def to_array
        components.to_normalized
      end
      alias to_a to_array

      def to_string
        "#{identifier}(#{components.to_string})"
      end
      alias inspect to_string
      alias to_s    to_string

      private

      def identity_attributes
        [self.class, components.identity, source_white&.identity].compact.freeze
      end
    end
  end
end
