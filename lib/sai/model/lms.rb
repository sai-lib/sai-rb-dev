# frozen_string_literal: true

module Sai
  class Model
    class LMS < Model
      channel :long, :l, :linear, display_precision: 6, differential_step: 0.0005
      channel :medium, :m, :linear, display_precision: 6, differential_step: 0.0005
      channel :short, :s, :linear, display_precision: 6, differential_step: 0.0005

      cache_channels_with_high_precision
    end
  end
end
