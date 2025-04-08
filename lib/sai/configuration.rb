# frozen_string_literal: true

module Sai
  class Configuration
    class << self
      def defaults
        @defaults ||= EMPTY_HASH
      end

      private

      def default(name, value, *valid_types)
        thread_lock.synchronize do
          attr_reader :"default_#{name}"

          @defaults = defaults.merge(name.to_sym => value).freeze

          define_method(:"set_default_#{name}") do |object|
            unless valid_types.any? { |type| type.is_a?(Proc) ? type.call(object) : object.is_a?(type) }
              raise TypeError, "`#{name}` is invalid. Expected `#{valid_types.join(' | ')}`, got #{object.inspect}"
            end

            instance_variable_set(:"@default_#{name}", object)
          end
        end
      end

      def thread_lock
        @thread_lock ||= Mutex.new
      end
    end

    def initialize
      self.class.defaults.each_pair { |attribute, value| instance_variable_set(:"@default_#{attribute}", value) }
    end
  end
end
