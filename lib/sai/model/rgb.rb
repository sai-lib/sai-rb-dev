# frozen_string_literal: true

module Sai
  module Model
    RGB = Definition.new(:RGB) do
      channel_range = 0.0..255.0

      component :red,   :r, :linear, bounds: channel_range
      component :green, :g, :linear, bounds: channel_range
      component :blue,  :b, :linear, bounds: channel_range
    end
  end
end
