# frozen_string_literal: true

module Sai
  class Model
    class HSL < Model
      channel :hue, :h, :hue_angle
      channel :saturation, :s, :percentage
      channel :lightness, :l, :percentage
    end
  end
end
