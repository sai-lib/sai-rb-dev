# frozen_string_literal: true

require 'sai/enum/value'

module Sai
  module Enum
    extend self
    using Inflection::CaseRefinements

    class << self
      private

      def extended(base)
        super

        basename = base.name.split('::').last
        parent = find_parent(base)

        parent.extend(Enum) unless parent.class < Enum || parent.singleton_class < Enum || parent == Enum
        parent.send(:thread_lock).synchronize do
          parent.const_set(basename, base) unless parent.const_defined?(basename)

          method_name = basename.to_snake_case
          return if parent.respond_to?(method_name)

          parent.define_singleton_method(method_name) { base }
        end
      end
    end

    def [](key)
      const_name = key.to_pascal_case.to_sym
      method_name = key.to_snake_case.to_sym

      if (enum = enums.find { |e| e.name.split('::').last == const_name.to_s })
        enum
      elsif values.key?(method_name)
        values[method_name]
      elsif const_defined?(const_name)
        const_get(const_name)
      elsif (value_const = const_name.upcase) && const_defined?(value_const)
        const_get(value_const)
      end
    end

    def dig(*keys)
      keys.reduce(self) do |accumulator, key|
        if accumulator.is_a?(Value)
          accumulator
        elsif enum?(accumulator)
          accumulator[key]
        end
      end
    end

    def enums
      @enums ||= constants.filter_map do |constant_name|
        const = const_get(constant_name)
        next unless enum?(const)

        const
      end.sort_by(&:name).freeze
    end

    def resolve(object)
      if object.is_a?(Value)
        object.resolve
      elsif (object.is_a?(String) || object.is_a?(Symbol)) &&
            (name = object.to_snake_case.to_sym) &&
            values.key?(name)
        values[name]
      else
        object
      end
    end

    def resolve_all
      values.values.map(&:resolve).freeze
    end

    def values
      @values ||= EMPTY_HASH
    end

    private

    def alias_value(new_name, old_name)
      thread_lock.synchronize do
        value = public_send(old_name)
        define_singleton_method(new_name) { value }
        const_set(new_name.upcase, value)
      end
    end

    def aliased_as(name)
      name = name.to_sym
      parent = find_parent(self)

      parent.send(:thread_lock).synchronize do
        mod = self
        parent.define_singleton_method(name.to_snake_case) { mod }
        parent.const_set(name, mod)
      end
    end

    def enum?(object)
      (object.is_a?(Module) || object.is_a?(Class)) && (object.singleton_class < Enum || object < Enum)
    end

    def find_parent(enum)
      basename = enum.name.split('::').last
      parent_module_path = enum.name
                               .gsub(Enum.name, '')
                               .gsub(basename, '')
                               .delete_prefix('::')
                               .delete_suffix('::')
                               .split('::')
      parent_module_path.reduce(Enum) do |accumulator, path|
        path ? accumulator.const_get(path) : accumulator
      end
    end

    def thread_lock
      @thread_lock ||= Mutex.new
    end

    def value(name, &)
      thread_lock.synchronize do
        value = Value.new(self.name, name, &)
        method_name = name.to_snake_case

        define_singleton_method(method_name) { value }
        const_set(method_name.upcase, value)

        @values = values.merge(name => value).freeze
      end
    end
  end
end

Dir.glob(File.expand_path('enum/**/*.rb', File.dirname(__FILE__))).each { |file| require file }
