# frozen_string_literal: true

module Sai
  class Illuminant
    module Normalization
      NONE               = :none
      STANDARD_LUMINANCE = :standard_luminance
      CIE_LUMINANCE      = :cie_luminance
      UNITY_PEAK         = :unity_peak
      UNITY_ENERGY       = :unity_energy

      ALL = [
        NONE,
        STANDARD_LUMINANCE,
        CIE_LUMINANCE,
        UNITY_PEAK,
        UNITY_ENERGY,
      ].freeze
    end
  end
end
