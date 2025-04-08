# frozen_string_literal: true

module Sai
  class Channel
    class Set
      include Enumerable

      CHANNEL_TYPES = {
        bipolar: [Channel::Bipolar, EMPTY_HASH].freeze,
        circular: [Channel::Circular, EMPTY_HASH].freeze,
        hue_angle: [Channel::Circular, { bounds: 0..360, display_format: '%.0f°' }.freeze].freeze,
        linear: [Channel::Linear, EMPTY_HASH].freeze,
        percentage: [
          Channel::Linear, { bounds: PERCENTAGE_RANGE, differential_step: 0.5, display_format: '%.1f%%' }.freeze,
        ].freeze,
      }.freeze

      def initialize
        @lookup = EMPTY_HASH
        @index = EMPTY_HASH
        @thread_lock = Mutex.new
      end

      def [](name_or_symbol)
        key = name_or_symbol.to_sym
        @lookup.fetch(key, @lookup[@index[key]])
      end

      def add(**options)
        @thread_lock.synchronize do
          channel_type, default_options = CHANNEL_TYPES[options[:type]]

          unless channel_type
            raise ArgumentError, "`:type` is invalid. Expected one of #{CHANNEL_TYPES.keys.join(', ')}, " \
                                 "got: #{options[:type]}"
          end

          options = default_options.merge(options.except(:type))
          channel = channel_type.new(**options)

          @lookup = @lookup.merge(channel.symbol => channel).freeze
          @index = @index.merge(channel.name => channel.symbol).freeze

          define_singleton_method(channel.name) { channel }
          define_singleton_method(channel.symbol) { channel } unless channel.symbol == channel.name

          channel
        end
      end

      def each(&)
        @lookup.values.each(&)
      end

      def length
        @lookup.length
      end
      alias size length

      def names
        @index.keys
      end

      def symbols
        @lookup.keys
      end

      def valid?(*channels)
        return false if channels.size < count(&:required?) || channels.size > size

        map.with_index do |channel, index|
          value = channels[index]
          next false unless value.is_a?(Numeric)
          next true if channel.boundary.unbound?

          channel.boundary.range.cover?(value)
        end.all?
      end
    end
  end
end
