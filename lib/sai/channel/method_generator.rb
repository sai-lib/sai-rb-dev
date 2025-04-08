# frozen_string_literal: true

module Sai
  class Channel
    module MethodGenerator
      class << self
        def call(base, channel)
          base.attr_reader(channel.symbol)

          base.define_method(channel.name) { instance_variable_get(:"@#{channel.symbol}").to_display }

          base.define_method(:"with_#{channel.name}") do |value|
            with_updated_channels(channel.symbol => channel.normalize(value))
          end

          define_channel_derivative_method(base, :contract, channel) do |channel_value, amount|
            channel_value / amount
          end

          define_channel_derivative_method(
            base, :decrement, channel, include_default_value: true
          ) do |channel_value, amount|
            channel_value - channel.normalize(amount)
          end

          define_channel_derivative_method(
            base, :increment, channel, include_default_value: true
          ) do |channel_value, amount|
            channel_value + channel.normalize(amount)
          end

          define_channel_derivative_method(base, :scale, channel) do |channel_value, amount|
            channel_value * amount
          end
        end

        private

        def define_channel_derivative_method(base, method_name, channel, include_default_value: false)
          channel_name = channel.name
          tensed_method_name = method_name.end_with?('e') ? :"#{method_name}d" : "#{method_name}ed"
          with_method_name = :"with_#{channel_name}_#{tensed_method_name}_by"
          aliased_name = :"#{method_name}_#{channel_name}"

          if include_default_value
            base.define_method(with_method_name) do |amount = channel.differential_step|
              channel_value = instance_variable_get(:"@#{channel.symbol}")
              new_value = yield(channel_value, amount)

              with_updated_channels(channel.symbol => new_value)
            end
          else
            base.define_method(with_method_name) do |amount|
              channel_value = instance_variable_get(:"@#{channel.symbol}")
              new_value = yield(channel_value, amount)

              with_updated_channels(channel.symbol => new_value)
            end
          end

          base.alias_method(aliased_name, with_method_name)
        end
      end
    end
  end
end
