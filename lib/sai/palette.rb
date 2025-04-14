# frozen_string_literal: true

module Sai
  class Palette
    autoload :Color, 'sai/palette/color'

    def initialize(**colors)
      @colors = EMPTY_HASH
      @thread_lock = Mutex.new

      colors.each_pair { |name, color| add(name, color) }
    end

    def [](name)
      @colors[name.to_sym]
    end

    def add(name, color)
      raise TypeError, "`color` is invalid. Expected `Sai::Model`, got: #{color.inspect}" unless color.is_a?(Model)

      color = Color.new(name, color)

      @thread_lock.synchronize do
        @colors = @colors.merge(color.name => color).freeze
        define_singleton_method(color.name) { color }
      end
    end

    def colors
      @colors.values.sort_by(&:name)
    end

    def with_encoding_specification(**options)
      new_colors = @colors.each_with_object({}) do |(name, color), result|
        result[name] = Color.new(name, color.with_encoding_specification(**options))
      end

      self.class.new(**new_colors)
    end
  end
end
