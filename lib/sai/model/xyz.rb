# frozen_string_literal: true

module Sai
  class Model
    class XYZ < Model
      channel :x, :x, :linear, display_precision: 6, differential_step: 0.001
      channel :y, :y, :linear, display_precision: 6, differential_step: 0.001
      channel :z, :z, :linear, display_precision: 6, differential_step: 0.001

      cache_channels_with_high_precision
    end
  end
end
