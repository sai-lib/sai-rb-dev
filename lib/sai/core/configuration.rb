# frozen_string_literal: true

module Sai
  module Core
    class Configuration
      include Concurrency

      class << self
        def defaults
          concurrent_instance_variable_fetch(:@defaults, EMPTY_HASH)
        end

        private

        def default(name, default_value = nil, &block)
          key = name.to_sym
          new_defaults = defaults.merge(key => { value: default_value || block }.freeze).freeze

          mutex.synchronize do
            define_method(:"default_#{key}") do
              ivar_value = instance_variable_get(:"@default_#{key}")
              return ivar_value unless ivar_value.is_a?(Proc)

              resolved_value = instance_exec(&ivar_value)
              mutex.synchronize { instance_variable_set(:"@default_#{key}", resolved_value) }
            end

            define_method(:"set_default_#{key}") do |value|
              validator, message = self.class.defaults[key][:validator]
              raise ConfigurationError, "#{key} #{message}" if validator && !instance_exec(value, &validator)

              mutex.synchronize { instance_variable_set(:"@default_#{key}", value) }
            end

            @defaults = new_defaults
          end
        end

        def validates(name, message, &block)
          new_defaults = defaults.dup
          new_defaults[name.to_sym] = new_defaults[name.to_sym].merge(validator: [block, message]).freeze
          mutex.synchronize { @defaults = new_defaults.freeze }
        end
      end

      def initialize
        self.class.defaults.each_pair do |attribute, config|
          instance_variable_set(:"@default_#{attribute}", config[:value])
        end
      end
    end
  end
end
