# frozen_string_literal: true

module Sai
  module Cache
    class NullStore < Store
      def initialize(...)
        super
        instance_variables.each { |ivar| instance_variable_set(ivar, nil) }
      end

      def [](...); end

      def []=(...); end

      def clear; end

      def count(&)
        0
      end

      def fetch(...)
        yield
      end
    end
  end
end
