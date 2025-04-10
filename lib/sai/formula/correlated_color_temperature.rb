# frozen_string_literal: true

module Sai
  module Formula
    module CorrelatedColorTemperature
      using Inflection::CaseRefinements

      autoload :HernandezAndres, 'sai/formula/correlated_color_temperature/hernandez_andres'
      autoload :McCamy,          'sai/formula/correlated_color_temperature/mc_camy'
      autoload :Ohno,            'sai/formula/correlated_color_temperature/ohno'
      autoload :Robertson,       'sai/formula/correlated_color_temperature/robertson'

      def self.recommended_method(source_type: nil, high_precision: false)
        case source_type
        when Enum::Illuminant::Type::DAYLIGHT
          HernandezAndres
        when Enum::Illuminant::Type::BLACKBODY
          high_precision ? Ohno : McCamy
        when Enum::Illuminant::Type::FLUORESCENT, Enum::Illuminant::Type::LED
          Robertson
        else
          McCamy
        end
      end
    end
  end
end
