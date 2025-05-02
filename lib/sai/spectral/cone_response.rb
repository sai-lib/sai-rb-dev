# frozen_string_literal: true

module Sai
  module Spectral
    class ConeResponse < Response
      implements Model::LMS

      class << self
        def coerce(other, **options)
          return new(*other.to_a, **options) if other.is_a?(self)
          return new(*other, **options) if other.is_a?(Array) && components.valid?(*other)
          return new(*other.components.to_normalized, **options) if Model::LMS === other

          raise ArgumentError, "#{other.inspect} is not coercible to #{self}"
        end
      end

      def initialize(*components, **options)
        super

        if options.key?(:source_white) && !Model::XYZ === options[:source_white]
          raise TypeError, '`:source_white` is invalid. Expected an object that implements `Sai::Model::XYZ` or ' \
                           "`[Numeric, Numeric, Numeric]` got: #{options[:source_white].inspect}"
        end

        @source_white = options.fetch(:source_white, Tristimulus.new(1, 1, 1))
      end
    end
  end
end
