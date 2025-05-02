# frozen_string_literal: true

module Sai
  module Core
    module Concurrency
      class << self
        private

        def extended(base)
          super

          base.instance_variable_set(:@_mutex, Mutex.new)
          base.extend ClassMethods
          base.extend InstanceVariables
        end

        def included(base)
          super

          base.extend self
          base.include InstanceMethods
          base.include InstanceVariables
        end
      end

      module InstanceVariables
        private

        def concurrent_instance_variable_fetch(name, value)
          return instance_variable_get(name) if instance_variable_defined?(name) && !instance_variable_get(name).nil?

          mutex.synchronize { instance_variable_set(name, value) }
        end
      end

      module ClassMethods
        private

        def inherited(subclass)
          super

          subclass.instance_variable_set(:@_mutex, Mutex.new)
        end

        def mutex
          @_mutex
        end
      end

      module InstanceMethods
        private

        def mutex
          return @_mutex if instance_variable_defined?(:@_mutex) && @_mutex

          self.class.send(:mutex).synchronize { @_mutex = Mutex.new }
        end
      end
    end
  end
end
