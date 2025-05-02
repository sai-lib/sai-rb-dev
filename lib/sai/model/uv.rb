# frozen_string_literal: true

module Sai
  module Model
    UV = Definition.new(:UV) do
      component :u, :u, :opponent,   display_precision: 2, differential_step: 0.02
      component :v, :v, :opponent,   display_precision: 2, differential_step: 0.02
    end
  end
end
