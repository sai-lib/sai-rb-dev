# frozen_string_literal: true

module Sai
  module Formula
    autoload :CCT,                        'sai/formula/correlated_color_temperature'
    autoload :CorrelatedColorTemperature, 'sai/formula/correlated_color_temperature'
    autoload :TypeFacade,                 'sai/formula/type_facade'

    extend TypeFacade
  end
end
