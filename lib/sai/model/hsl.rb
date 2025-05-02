# frozen_string_literal: true

module Sai
  module Model
    HSL = Definition.new(:HSL) do
      component :hue,        :h, :hue_angle
      component :saturation, :s, :percentage
      component :lightness,  :l, :percentage
    end
  end
end
