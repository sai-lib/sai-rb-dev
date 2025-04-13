# frozen_string_literal: true

module Sai
  module Enum
    module Formula
      module Contrast
        extend Enum

        value(:apca) { Sai::Formula::Contrast::APCA }

        value(:cie_lab) { Sai::Formula::Contrast::CIELab }

        value(:mbs) { Sai::Formula::Contrast::MBS }

        value(:michelson) { Sai::Formula::Contrast::Michelson }

        value(:rms) { Sai::Formula::Contrast::RMS }

        value(:sapc) { Sai::Formula::Contrast::SAPC }

        value(:wcag) { Sai::Formula::Contrast::WCAG }

        value(:weber) { Sai::Formula::Contrast::Weber }
      end

      module CorrelatedColorTemperature
        extend Enum

        aliased_as :CCT

        value(:hernandez_andres) { Sai::Formula::CorrelatedColorTemperature::HernandezAndres }

        value(:mc_camy) { Sai::Formula::CorrelatedColorTemperature::McCamy }

        value(:ohno) { Sai::Formula::CorrelatedColorTemperature::Ohno }

        value(:robertson) { Sai::Formula::CorrelatedColorTemperature::Robertson }
      end

      module Distance
        extend Enum

        module Application
          extend Enum

          value(:graphic_arts) { :graphic_arts }

          value(:textile) { :textile }
        end

        value(:cie76) { Sai::Formula::Distance::CIE76 }

        value(:cie94) { Sai::Formula::Distance::CIE94 }

        value(:cie_cmc) { Sai::Formula::Distance::CIECMC }

        value(:cie_de2000) { Sai::Formula::Distance::CIEDE2000 }

        value(:delta_e) { Sai::Formula::Distance::DeltaE }

        value(:euclidean) { Sai::Formula::Distance::Euclidean }

        value(:manhattan) { Sai::Formula::Distance::Manhattan }
      end
    end
  end
end
