# frozen_string_literal: true

module Sai
  class WavelengthRange
    include Enumerable

    attr_reader :begin
    alias min begin
    alias minimum begin

    attr_reader :end
    alias max end
    alias maximum end

    attr_reader :step

    def initialize(wavelengths)
      unless wavelengths.is_a?(Hash) && wavelengths.keys.all?(Integer)
        raise TypeError, "`wavelengths` is invalid. Expected `Hash[Integer, Object]`, got: #{wavelengths.inspect}"
      end

      @step = wavelengths.keys[1] - wavelengths.keys[0]
      wavelengths.keys.each_cons(2) do |current, next_key|
        step = next_key - current
        raise UnevenWavelengthError, '`wavelengths` are not evenly spaced' if step != @step
      end

      @begin = wavelengths.keys.min
      @end = wavelengths.keys.max
      @table = wavelengths.dup.freeze
      freeze
    end

    def ==(other)
      other.is_a?(self.class) && other.instance_variable_get(:@table) == @table
    end

    def [](wavelength)
      @table[wavelength]
    end
    alias at []

    def each_pair(&)
      @table.each_pair(&)
    end
    alias each each_pair

    def hash
      @table.hash
    end

    def maximum_value
      @table.values.max
    end
    alias max_value maximum_value

    def minimum_value
      @table.values.min
    end
    alias min_value minimum_value

    def sum_values(&)
      @table.values.sum(&)
    end

    def transform_values(&)
      new_values = @table.transform_values(&)
      self.class.new(new_values)
    end

    def within(*range_or_min_max)
      range = if range_or_min_max.size == 1 && range_or_min_max.first.is_a?(Range)
                range_or_min_max.first
              elsif range_or_min_max.size == 2 && range_or_min_max.all?(Numeric)
                range_or_min_max.min..range_or_min_max.max
              else
                raise ArgumentError, 'must provide a `Range` or a minimum and maximum `Numeric`'
              end

      self.class.new(@table.select { |wavelength, _| range.cover?(wavelength) })
    end
  end
end
