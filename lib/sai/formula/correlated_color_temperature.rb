# frozen_string_literal: true

module Sai
  module Formula
    module CorrelatedColorTemperature
      autoload :HernandezAndres, 'sai/formula/correlated_color_temperature/hernandez_andres'
      autoload :McCamy,          'sai/formula/correlated_color_temperature/mc_camy'
      autoload :Ohno,            'sai/formula/correlated_color_temperature/ohno'
      autoload :Robertson,       'sai/formula/correlated_color_temperature/robertson'

      extend TypeFacade
    end

    CCT = CorrelatedColorTemperature
  end
end
