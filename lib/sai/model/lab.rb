# frozen_string_literal: true

module Sai
  module Model
    LAB = Definition.new(:LAB) do
      component :lightness, :l, :percentage, display_precision: 2, differential_step: 0.02
      component :a,         :a, :opponent,   display_precision: 2, differential_step: 0.02
      component :b,         :b, :opponent,   display_precision: 2, differential_step: 0.02
    end
  end
end
