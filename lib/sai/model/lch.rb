# frozen_string_literal: true

module Sai
  module Model
    LCH = Definition.new(:LCH) do
      component :lightness, :l, :percentage, display_precision: 2, differential_step: 0.02
      component :chroma,    :c, :linear,     display_precision: 2, differential_step: 0.05
      component :hue,       :h, :hue_angle
    end
  end
end
