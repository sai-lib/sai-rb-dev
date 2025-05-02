# frozen_string_literal: true

module Sai
  module Formula
    module CorrelatedColorTemperature
      autoload :HernandezAndres, 'sai/formula/correlated_color_temperature/hernandez_andres'
      autoload :McCamy,          'sai/formula/correlated_color_temperature/mc_camy'
      autoload :Ohno,            'sai/formula/correlated_color_temperature/ohno'
      autoload :Robertson,       'sai/formula/correlated_color_temperature/robertson'

      extend TypeFacade

      class << self
        def recommended_method(source_type: nil, high_precision: false)
          case source_type
          when Illuminant::Type::DAYLIGHT
            HernandezAndres
          when Illuminant::Type::BLACKBODY
            high_precision ? Ohno : McCamy
          when Illuminant::Type::FLUORESCENT, Illuminant::Type::LED
            Robertson
          else
            Sai.config.default_correlated_color_temperature_formula
          end
        end
      end
    end

    CCT = CorrelatedColorTemperature
  end
end
