# frozen_string_literal: true

module Sai
  module Model
    XYZ = Definition.new(:XYZ) do
      component :x, :x, :linear, display_precision: 6, differential_step: 0.0001
      component :y, :y, :linear, display_precision: 6, differential_step: 0.0001
      component :z, :z, :linear, display_precision: 6, differential_step: 0.0001
    end
  end
end
