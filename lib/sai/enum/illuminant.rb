# frozen_string_literal: true

module Sai
  module Enum
    module Illuminant
      module Type
        extend Enum

        value(:blackbody) { :blackbody }

        value(:custom) { :custom }

        value(:daylight) { :daylight }

        value(:equal_energy) { :equal_energy }

        value(:fluorescent) { :fluorescent }

        value(:gas_discharge) { :gas_discharge }

        value(:incandescent) { :incandescent }

        value(:led) { :led }

        value(:narrow_band) { :narrow_band }
      end
    end
  end
end
