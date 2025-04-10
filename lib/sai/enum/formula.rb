# frozen_string_literal: true

module Sai
  module Enum
    module Formula
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
