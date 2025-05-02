# frozen_string_literal: true

module Sai
  module Model
    module Component
      module Definition
        class Base
          include Core::Identity

          Display = Struct.new(:format, :precision, keyword_init: true)

          attr_reader :boundary
          attr_reader :differential_step
          attr_reader :display
          attr_reader :identifier
          attr_reader :name

          def initialize(identifier:, name:, bounds: nil, differential_step: 0.01, display_format: nil,
                         display_precision: 0, optional: false)
            @boundary          = Boundary.new(bounds)
            @differential_step = differential_step
            @display           = Display.new(
              format: display_format || "%.#{display_precision}f",
              precision: display_precision,
            ).freeze
            @name     = name.to_sym
            @required = !optional
            @identifier = identifier.to_sym
          end

          def ==(other)
            other.is_a?(self.class) && other.identity == identity
          end

          def contract(value, amount); end

          def decrement(value, amount); end

          def denormalize(value); end

          def exponentiate(value, amount); end

          def increment(value, amount); end

          def normalize(value); end

          def required?
            @required
          end

          def scale(value, amount); end

          private

          def identity_attributes
            [
              self.class,
              name,
              identifier,
              boundary.max,
              boundary.min,
              differential_step,
              display.format,
              display.precision,
              required?,
            ].freeze
          end
        end
      end
    end
  end
end
