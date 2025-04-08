# frozen_string_literal: true

module Sai
  class Model
    class Oklch < Model
      channel :lightness, :l, :percentage, display_precision: 2, differential_step: 0.2
      channel :chroma, :c, :linear, display_precision: 2, differential_step: 0.5
      channel :hue, :h, :hue_angle
    end
  end
end
