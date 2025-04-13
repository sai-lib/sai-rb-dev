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
    end
  end
end
