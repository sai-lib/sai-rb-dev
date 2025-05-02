# frozen_string_literal: true

module Sai
  module Core
    module DefferedConstant
      class << self
        private

        def extended(base)
          super

          base.extend Concurrency
          base.extend ClassMethods
        end
      end

      module ClassMethods
        def const_missing(symbol)
          return super unless deffered_constants.key?(symbol)

          new_deffered_constants = deffered_constants.dup
          value = new_deffered_constants.delete(symbol).call
          new_deffered_constants.freeze

          mutex.synchronize do
            @deffered_constants = new_deffered_constants
            const_set(symbol, value)
          end
        end

        def constants
          super + deffered_constants.keys
        end

        private

        def alias_deffered_constant(new_name, old_name)
          deffered_constant(new_name) { const_get(old_name) }
        end

        def deffered_constant(symbol, &block)
          new_deffered_constants = deffered_constants.merge(symbol => block).freeze
          mutex.synchronize { @deffered_constants = new_deffered_constants }
        end

        def deffered_constants
          concurrent_instance_variable_fetch(:@deffered_constants, EMPTY_HASH)
        end
      end
    end
  end
end
