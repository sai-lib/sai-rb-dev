# frozen_string_literal: true

module Sai
  module Space
    module Core
      module Comparison
        class << self
          private

          def included(base)
            super

            base.include InstanceMethods
          end
        end

        module InstanceMethods
          def ==(other)
            (other.is_a?(self.class) && other.identity == identity) ||
              (other.is_a?(Space) && coerce(other).identity == identity) ||
              (self.class.model === other && coerce(other).identity == identity)
          end

          def is_a?(mod)
            mod == Space ||
              (mod.respond_to?(:name) && mod.name.start_with?(Space.name) && self.class.name.start_with?(mod.name)) ||
              super
          end
        end
      end
    end
  end
end
