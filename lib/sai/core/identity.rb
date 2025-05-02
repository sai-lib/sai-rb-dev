# frozen_string_literal: true

require 'digest'

module Sai
  module Core
    module Identity
      class << self
        def generate(object)
          serialized = if object.respond_to?(:identity_attributes, true)
                         Marshal.dump(object.send(:identity_attributes))
                       else
                         Marshal.dump(object)
                       end
          Digest::SHA256.hexdigest(serialized)
        rescue StandardError => e
          raise e if e.is_a?(Sai::Error)

          raise IdentityError, "Failed to generate identity for #{object}: #{e.message}"
        end

        private

        def included(base)
          super

          base.include InstanceMethods
          base.include Concurrency
        end
      end

      module InstanceMethods
        def identity
          concurrent_instance_variable_fetch(:@identity, Identity.generate(self))
        end
      end
    end
  end
end
