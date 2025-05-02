# frozen_string_literal: true

module Sai
  module Model
    HSV = Definition.new(:HSV) do
      component :hue,        :h, :hue_angle
      component :saturation, :s, :percentage
      component :value,      :v, :percentage
    end
  end
end
