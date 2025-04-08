# frozen_string_literal: true

module Sai
  module Enum
    class Value
      attr_reader :name
      attr_reader :path

      def initialize(path, name, &resolver)
        @name = name
        @path = path
        @resolver = resolver
      end

      def ===(other)
        resolve === other || super
      end

      def is_a?(mod)
        mod_name = mod.is_a?(Class) || mod.is_a?(Module) ? mod.name : mod
        path == mod_name || super
      end

      def resolve
        @resolve ||= @resolver.call
      end

      private

      def method_missing(method_name, ...)
        return super unless respond_to_missing?(method_name)

        resolve.public_send(method_name, ...)
      end

      def respond_to_missing?(method_name, _include_private = false)
        resolve.respond_to?(method_name) || super
      end
    end
  end
end
