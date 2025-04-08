# frozen_string_literal: true

module Sai
  class Model
    class Lab < Model
      channel :lightness, :l, :percentage, display_precision: 2, differential_step: 0.2
      channel :a, :a, :bipolar, display_precision: 2, differential_step: 0.2
      channel :b, :b, :bipolar, display_precision: 2, differential_step: 0.2

      cache_channels_with_high_precision
    end
  end
end
