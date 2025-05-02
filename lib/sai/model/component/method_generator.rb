# frozen_string_literal: true

module Sai
  module Model
    module Component
      module MethodGenerator
        class << self
          def call(base, component)
            base.define_method(component.identifier) { components[component.identifier] }

            unless component.name == component.identifier
              base.define_method(component.name) { components[component.identifier].to_display }
            end

            base.define_method(:"with_#{component.name}") do |value|
              with_components(component.identifier => component.normalize(value), normalized: true)
            end

            define_component_derivative_method(base, :contract, component) do |component_value, amount|
              component_value / amount
            end

            define_component_derivative_method(
              base, :decrement, component, include_default_value: true
            ) do |component_value, amount|
              component_value - component.normalize(amount)
            end

            define_component_derivative_method(
              base, :increment, component, include_default_value: true
            ) do |component_value, amount|
              component_value + component.normalize(amount)
            end

            define_component_derivative_method(base, :scale, component) do |component_value, amount|
              component_value * amount
            end
          end

          private

          def define_component_derivative_method(base, method_name, component, include_default_value: false)
            component_name = component.name
            tensed_method_name = method_name.end_with?('e') ? :"#{method_name}d" : "#{method_name}ed"
            with_method_name = :"with_#{component_name}_#{tensed_method_name}_by"
            aliased_name = :"#{method_name}_#{component_name}"

            if include_default_value
              base.define_method(with_method_name) do |amount = component.differential_step|
                new_value = yield(components[component.identifier], amount)
                with_components(component.identifier => new_value, normalized: true)
              end
            else
              base.define_method(with_method_name) do |amount|
                new_value = yield(components[component.identifier], amount)
                with_components(component.identifier => new_value, normalized: true)
              end
            end

            base.alias_method(aliased_name, with_method_name)
          end
        end
      end
    end
  end
end
