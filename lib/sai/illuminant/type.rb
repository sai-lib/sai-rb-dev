# frozen_string_literal: true

module Sai
  class Illuminant
    module Type
      BLACKBODY     = :blackbody
      CUSTOM        = :custom
      DAYLIGHT      = :daylight
      EQUAL_ENERGY  = :equal_energy
      FLUORESCENT   = :fluorescent
      GAS_DISCHARGE = :gas_discharge
      INCANDESCENT  = :incandescent
      LED           = :led
      NARROW_BAND   = :narrow_band

      ALL = [
        BLACKBODY,
        CUSTOM,
        DAYLIGHT,
        EQUAL_ENERGY,
        FLUORESCENT,
        GAS_DISCHARGE,
        INCANDESCENT,
        LED,
        NARROW_BAND,
      ].freeze
    end
  end
end
