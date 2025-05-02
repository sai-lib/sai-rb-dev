# frozen_string_literal: true

module Sai
  module Spectral
    class Table
      include Enumerable
      include Core::Concurrency
      include Core::Identity

      attr_reader :begin
      alias min     begin
      alias minimum begin

      attr_reader :end
      alias max     end
      alias maximum end

      attr_reader :responses
      attr_reader :step

      class << self
        attr_reader :response_type

        def coerce(data)
          return data if @response_coercer.nil?

          unless data.is_a?(Hash)
            raise TypeError, "`data` is invalid. Expected `Hash[Integer, Object]`, got #{data.inspect}"
          end

          new(@response_coercer.call(data))
        rescue StandardError => e
          raise e if e.is_a?(Error)

          raise ArgumentError, "`data` is not coercible to #{self}: #{e.message}"
        end

        private

        def coerce_responses_with(&coercer)
          mutex.synchronize { @response_coercer = coercer }
        end

        def with_responses(type)
          mutex.synchronize { @response_type = type }
        end
      end

      def initialize(data)
        unless data.is_a?(Hash) && data.keys.all?(Integer) && data.values.all?(self.class.response_type)
          raise TypeError,
                "`data` is invalid. Expected `Hash[Integer, #{self.class.response_type}]`, got #{data.inspect}"
        end

        @step = data.keys[1] - data.keys[0]
        data.keys.each_cons(2) do |a, b|
          raise UnevenWavelengthError if (b - a) != @step
        end

        @begin     = data.keys.min
        @end       = data.keys.max
        @responses = data.dup.freeze
      end

      def ==(other)
        other.is_a?(self.class) && other.identity == identity
      end

      def at(wavelength)
        responses[wavelength]
      end
      alias [] at

      def count(&)
        responses.count(&)
      end

      def each_pair(&)
        responses.each_pair(&)
        self
      end
      alias each each_pair

      def length
        responses.length
      end
      alias size length

      def maximum_response
        at(max)
      end
      alias max_response maximum_response

      def minimum_response
        at(min)
      end
      alias min_response minimum_response

      def pretty_print(pp)
        pp.group(1, "#<#{inspect.gsub('#<', '').gsub(' ...>', '')}", '>') do
          pp.text(" #{size}")
          pp.text(" #{self.class.response_type} samples between wavelengths ")
          pp.text(self.begin)
          pp.text(' and ')
          pp.text(self.end)
          pp.text(' at ')
          pp.text(step)
          pp.text('nm intervals')
        end
      end

      def sum_responses(&)
        responses.values.sum(&)
      end

      def within(*range_or_min_max)
        range = if range_or_min_max.size == 1 && range_or_min_max.first.is_a?(Range)
                  range_or_min_max.first
                elsif range_or_min_max.size == 2 && range_or_min_max.all?(Integer)
                  range_or_min_max.min..range_or_min_max.max
                else
                  raise ArgumentError, 'must provide a `Range` or minimum, maximum `Numeric`s'
                end
        self.class.new(responses.select { |wavelength, _| range.cover?(wavelength) })
      end

      private

      def identity_attributes
        response_identity = responses.transform_values do |value|
          value.respond_to?(:identity) ? value.identity : value
        end

        [self.class, response_identity].freeze
      end
    end
  end
end
