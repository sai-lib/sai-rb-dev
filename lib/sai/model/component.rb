# frozen_string_literal: true

module Sai
  module Model
    module Component
      autoload :Definition,      'sai/model/component/definition'
      autoload :MethodGenerator, 'sai/model/component/method_generator'
      autoload :Set,             'sai/model/component/set'
      autoload :Value,           'sai/model/component/value'

      class << self
        private

        def included(base)
          super

          base.extend  ClassMethods
          base.include InstanceMethods
          base.include Core::Concurrency
        end
      end

      module Definition
      end

      module ClassMethods
        def components
          concurrent_instance_variable_fetch(:@components, Definition::Set.new)
        end

        private

        def inherited(subclass)
          super

          subclass.send(:mutex).synchronize { subclass.instance_variable_set(:@components, components.dup) }
        end
      end

      module InstanceMethods
        attr_reader :components

        def with_components(normalized: false, **components)
          duped = dup
          duped.instance_variable_set(:@components, self.components.with(duped, normalized:, **components))
          duped.send(:on_component_update)
          duped
        end

        private

        def initialize_components!(*components, **options)
          component_map = self.class.components.each_with_object({}).with_index do |(definition, result), index|
            result[definition.identifier] = components[index]
          end

          @components = Component::Set.new(
            self,
            normalized: options.fetch(:normalized, false),
            **component_map,
          )

          return unless options.fetch(:validate, true) && !@components.valid?

          raise InvalidColorValueError, "#{self.class} values #{components.join(', ')} are invalid"
        end

        def on_component_update; end
      end
    end
  end
end
