# frozen_string_literal: true

module Sai
  module Model
    class Definition
      attr_reader :components
      attr_reader :name

      def initialize(name, &block)
        @name = "Sai::Model::#{name}"
        @components = Component::Definition::Set.new

        block&.arity&.zero? ? instance_exec(&block) : (yield(self) if block)
      end

      def coercible_to?(object)
        implemented_by?(object) || (object.is_a?(Array) && components.valid?(*object))
      end
      alias === coercible_to?

      def component(name, identifier, type, **options)
        components.push(name:, identifier:, type:, **options)
      end

      def implement(base)
        base.include Core::Concurrency
        base.include Component

        base.send(:mutex).synchronize do
          base.instance_variable_set(:@components, components)
          components.each { |component| Component::MethodGenerator.call(base, component) }
        end
      end

      def implemented_by?(object)
        object.class.respond_to?(:components) && object.class.components == components
      end
    end
  end
end
