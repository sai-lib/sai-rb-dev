# frozen_string_literal: true

module Sai
  module Space
    class Base
      include Sai::Core::Concurrency
      include Sai::Core::Identity
      include Sai::Core::ManagedAttributes
      include Core::Coercion
      include Core::Comparison
      include Core::Configuration
      include Core::Context
      include Core::Conversion
      include Core::Derivation
      include Core::Harmony
      include Core::Gamut
      include Core::Introspection
      include Core::Opacity

      abstract_space

      def initialize(*components, **options)
        if self.class.abstract_space?
          raise InstantiationError, "#{self.class} is an abstract space and cannot be instantiated."
        end

        if components.size == 1 && components.first.is_a?(String) && Encoded::RGB::HEX_PATTERN.match?(components.first)
          components = self.class.from_hex(components.first, **options).components.to_unnormalized
        end

        initialize_components!(*components, **options)
        initialize_opacity!(**options)
        initialize_context!(**options)
        initialize_attributes!(**options)
      end
    end
  end
end
