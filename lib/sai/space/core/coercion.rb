# frozen_string_literal: true

module Sai
  module Space
    module Core
      module Coercion
        class << self
          private

          def included(base)
            super

            base.extend  ClassMethods
            base.include BasicInstanceMethods
          end
        end

        module ClassMethods
          def coerce(other)
            return other if other.is_a?(self)
            return other.public_send(:"to_#{identifier}") if other.is_a?(Space)
            return new(*other) if other.is_a?(Array) && model === other
            return from_fraction(*other.components.to_normalized) if model === other

            raise ArgumentError, "#{other.inspect} is not coercible to #{self}"
          end

          def from_fraction(*components, **options)
            new(*components, **options, normalized: true)
          end

          def from_hex(hex, **_options)
            raise ArgumentError, "#{hex} is invalid." unless Encoded::RGB::HEX_PATTERN.match?(hex)

            hex = hex.delete_prefix('#')
            hex = hex.chars.map { |char| char * 2 }.join if hex.length == 3
            rgb = Sai.config.default_rgb_space.new(hex[0..1].to_i(16), hex[2..3].to_i(16), hex[4..5].to_i(16))
            coerce(rgb)
          end

          def from_intermediate(*components, **options)
            from_fraction(*components, **options, validate: false)
          end

          def from_percentage(*components, **options)
            components = components.map { |component| component / PERCENTAGE_RANGE.end }
            from_fraction(*components, **options)
          end
        end

        module BasicInstanceMethods
          def coerce(other)
            self.class.coerce(other)
          end
        end
      end
    end
  end
end
