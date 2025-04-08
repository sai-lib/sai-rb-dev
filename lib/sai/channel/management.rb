# frozen_string_literal: true

module Sai
  class Channel
    module Management
      class << self
        private

        def included(base)
          super

          base.extend ClassMethods
        end
      end

      module ClassMethods
        def channel_cache_method
          @channel_cache_method ||= :unnormalized
        end

        def channels
          @channels ||= Set.new
        end

        def from_fraction(*channels, **options)
          new(*channels, **options, normalized: true)
        end

        def from_percentage(*channels, **options)
          channels = self.channels.map.with_index do |config, index|
            next if channels[index].nil?

            channels[index].to_f / config.normalize(PERCENTAGE_RANGE.end)
          end

          new(*channels, **options)
        end

        def intermediate(*channels, **options)
          from_fraction(*channels, **options, validate: false)
        end

        private

        def cache_channels_with_high_precision
          thread_lock.synchronize do
            @channel_cache_method = :normalized
          end
        end

        def channel(name, symbol, type, **options)
          thread_lock.synchronize do
            channel = channels.add(name:, symbol:, type:, **options)
            MethodGenerator.call(self, channel)
          end
        end

        def inherited(subclass)
          super

          subclass.send(:thread_lock).synchronize { subclass.instance_variable_set(:@channels, channels.dup) }
        end

        def thread_lock
          @thread_lock ||= Mutex.new
        end
      end

      def channel_cache_key
        self.class.channels.map do |channel|
          instance_variable_get(:"@#{channel.symbol}").public_send(self.class.channel_cache_method)
        end
      end

      def valid?
        config = self.class.channels
        channels = config.map do |channel|
          instance_variable_get(:"@#{channel.symbol}")&.unnormalized
        end
        config.valid?(*channels)
      end

      private

      def initialize_channels(*channels, **options)
        config = self.class.channels

        if options.fetch(:validate, true) && !config.valid?(*channels)
          raise InvalidColorValueError, "#{self.class} values #{channels.join(', ')} are invalid"
        end

        config.each_with_index do |channel, index|
          value = channels[index]
          next if value.nil?

          instance_variable_set(
            :"@#{channel.symbol}",
            Value.new(value, channel, normalized: options.fetch(:normalized, false)),
          )
        end
      end

      def with_updated_channels(normalized: true, **channel_map)
        dup.tap do |duped|
          self.class.channels.each do |channel|
            next unless channel_map.key?(channel.symbol)

            value = Channel::Value.new(channel_map[channel.symbol], channel, normalized:)
            duped.instance_variable_set(:"@#{channel.symbol}", value)
          end
        end
      end
    end
  end
end
