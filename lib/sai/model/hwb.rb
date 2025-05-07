# frozen_string_literal: true

module Sai
  module Model
    HWB = Definition.new(:HWB) do
      component :hue,       :h, :hue_angle
      component :whiteness, :w, :percentage
      component :blackness, :b, :percentage
    end
  end
end
