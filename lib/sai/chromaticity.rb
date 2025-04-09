# frozen_string_literal: true

module Sai
  class Chromaticity
    include Channel::Management

    channel :x, :x, :linear, display_precision: 16, differential_step: 0.0001
    channel :y, :y, :linear, display_precision: 16, differential_step: 0.0001

    cache_channels_with_high_precision

    attr_reader :z

    def self.from_xyz(xyz)
      raise TypeError, "`:xyz` is invalid. Expected `Model::XYZ`, got: #{xyz.inspect}" unless xyz.is_a?(Model::XYZ)

      x, y = Sai.cache.fetch(Chromaticity, :from_xyz, *xyz.channel_cache_key) do
        x, y, z = xyz.to_a
        sum = x + y + z

        if sum.zero?
          [0.0, 0.0]
        else
          [x / sum, y / sum]
        end
      end

      new(x, y)
    end

    def initialize(*channels, **options)
      initialize_channels(*channels, **options)
      @z = Channel::Value.new(
        1.0 - x - y,
        Channel::Linear.new(name: :z, symbol: :z, display_precision: 16, differential_step: 0.0001),
      )
      freeze
    end

    def ==(other)
      other.is_a?(self.class) && other.to_n_a == to_n_a
    end

    def to_array
      self.class.channels.map { |channel| instance_variable_get(:"@#{channel.symbol}") }
    end
    alias to_a to_array

    def to_normalized_array
      to_array.map(&:normalized)
    end
    alias to_n_a to_normalized_array

    def to_string
      channels = self.class.channels.map { |channel| instance_variable_get(:"@#{channel.symbol}").to_s }
      channels << z.to_s

      "chromaticity(#{channels.join(', ')})".freeze
    end
    alias inspect to_string
    alias to_s    to_string

    def to_unnormalized_array
      to_array.map(&:unnormalized)
    end
    alias to_un_a to_unnormalized_array

    def to_xyz(luminance = 1.0)
      nx, ny, nz = Sai.cache.fetch(Chromaticity, :to_xyz, *channel_cache_key, luminance) do
        if y.zero?
          [0.0, 0.0, 0.0]
        else
          [(x / y) * luminance, luminance, (z / y) * luminance]
        end
      end
      Model::XYZ.new(nx, ny, nz)
    end
  end
end
