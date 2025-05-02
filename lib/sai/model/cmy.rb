# frozen_string_literal: true

module Sai
  module Model
    CMY = Definition.new(:CMY) do
      component :cyan,    :c, :percentage, differential_step: 0.005
      component :magenta, :m, :percentage, differential_step: 0.005
      component :yellow,  :y, :percentage, differential_step: 0.005
    end
  end
end
