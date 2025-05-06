# frozen_string_literal: true

module Sai
  class Palette
    include Core::Concurrency

    def initialize(**colors)
      @colors = EMPTY_HASH
      @space  = nil

      colors.each_pair { |name, color| add(name, color) }
    end

    def [](name)
      found = @colors[name.to_sym]
      return unless found

      @space.nil? ? found.dup : found.public_send(:"to_#{@space.identifier}")
    end

    def add(name, color)
      raise TypeError, "`color` is invalid. Expected `Sai::Space`, got: #{color.inspect}" unless color.is_a?(Space)

      name = name.to_sym
      new_colors = @colors.merge(name => color.to_xyz).freeze

      mutex.synchronize do
        @colors = new_colors
        define_singleton_method(name) { @colors[name] }
      end
    end

    def colors
      @colors.map { |name, color| [name, color] }.sort_by(&:first).map(&:last)
    end

    def return_as(space)
      unless space.is_a?(Class) && space.name.start_with?(Space.name) && space.respond_to?(:abstract_space?) &&
             !space.abstract_space?
        raise ArgumentError, "`space` is invalid. Expected subclass of `Sai::Space`, got: #{space.inspect}"
      end

      mutex.synchronize { @space = space }
    end
  end
end
