# frozen_string_literal: true

module Sai
  module Enum
    # rubocop:disable Naming/VariableNumber

    module Illuminant
      extend Enum

      module Normalization
        extend Enum

        value(:none) { :none }

        value(:standard_luminance) { :standard_luminance }

        value(:cie_luminance) { :cie_luminance }

        value(:unity_peak) { :unity_peak }

        value(:unity_energy) { :unity_energy }
      end

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

      value(:a) { Sai::Illuminant.load('illuminant/a.yml', symbolize_names: true) }

      value(:b) { Sai::Illuminant.load('illuminant/b.yml', symbolize_names: true) }

      value(:c) { Sai::Illuminant.load('illuminant/c.yml', symbolize_names: true) }

      value(:d50) { Sai::Illuminant.load('illuminant/d50.yml', symbolize_names: true) }

      value(:d55) { Sai::Illuminant.load('illuminant/d55.yml', symbolize_names: true) }

      value(:d60) { Sai::Illuminant.load('illuminant/d60.yml', symbolize_names: true) }

      value(:d65) { Sai::Illuminant.load('illuminant/d65.yml', symbolize_names: true) }

      value(:d75) { Sai::Illuminant.load('illuminant/d75.yml', symbolize_names: true) }

      value(:e) { Sai::Illuminant.load('illuminant/e.yml', symbolize_names: true) }

      value(:fl1) { Sai::Illuminant.load('illuminant/fl1.yml', symbolize_names: true) }

      value(:fl2) { Sai::Illuminant.load('illuminant/fl2.yml', symbolize_names: true) }

      value(:fl3) { Sai::Illuminant.load('illuminant/fl3.yml', symbolize_names: true) }

      value(:fl3_1) { Sai::Illuminant.load('illuminant/fl3_1.yml', symbolize_names: true) }

      value(:fl3_2) { Sai::Illuminant.load('illuminant/fl3_2.yml', symbolize_names: true) }

      value(:fl3_3) { Sai::Illuminant.load('illuminant/fl3_3.yml', symbolize_names: true) }

      value(:fl3_4) { Sai::Illuminant.load('illuminant/fl3_4.yml', symbolize_names: true) }

      value(:fl3_5) { Sai::Illuminant.load('illuminant/fl3_5.yml', symbolize_names: true) }

      value(:fl3_6) { Sai::Illuminant.load('illuminant/fl3_6.yml', symbolize_names: true) }

      value(:fl3_7) { Sai::Illuminant.load('illuminant/fl3_7.yml', symbolize_names: true) }

      value(:fl3_8) { Sai::Illuminant.load('illuminant/fl3_8.yml', symbolize_names: true) }

      value(:fl3_9) { Sai::Illuminant.load('illuminant/fl3_9.yml', symbolize_names: true) }

      value(:fl3_10) { Sai::Illuminant.load('illuminant/fl3_10.yml', symbolize_names: true) }

      value(:fl3_11) { Sai::Illuminant.load('illuminant/fl3_11.yml', symbolize_names: true) }

      value(:fl3_12) { Sai::Illuminant.load('illuminant/fl3_12.yml', symbolize_names: true) }

      value(:fl3_13) { Sai::Illuminant.load('illuminant/fl3_13.yml', symbolize_names: true) }

      value(:fl3_14) { Sai::Illuminant.load('illuminant/fl3_14.yml', symbolize_names: true) }

      value(:fl3_15) { Sai::Illuminant.load('illuminant/fl3_15.yml', symbolize_names: true) }

      value(:fl4) { Sai::Illuminant.load('illuminant/fl4.yml', symbolize_names: true) }

      value(:fl5) { Sai::Illuminant.load('illuminant/fl5.yml', symbolize_names: true) }

      value(:fl6) { Sai::Illuminant.load('illuminant/fl6.yml', symbolize_names: true) }

      value(:fl7) { Sai::Illuminant.load('illuminant/fl7.yml', symbolize_names: true) }

      value(:fl8) { Sai::Illuminant.load('illuminant/fl8.yml', symbolize_names: true) }

      value(:fl9) { Sai::Illuminant.load('illuminant/fl9.yml', symbolize_names: true) }

      value(:fl10) { Sai::Illuminant.load('illuminant/fl10.yml', symbolize_names: true) }

      value(:fl11) { Sai::Illuminant.load('illuminant/fl11.yml', symbolize_names: true) }

      value(:fl12) { Sai::Illuminant.load('illuminant/fl12.yml', symbolize_names: true) }

      value(:hp1) { Sai::Illuminant.load('illuminant/hp1.yml', symbolize_names: true) }

      value(:hp2) { Sai::Illuminant.load('illuminant/hp2.yml', symbolize_names: true) }

      value(:hp3) { Sai::Illuminant.load('illuminant/hp3.yml', symbolize_names: true) }

      value(:hp4) { Sai::Illuminant.load('illuminant/hp4.yml', symbolize_names: true) }

      value(:hp5) { Sai::Illuminant.load('illuminant/hp5.yml', symbolize_names: true) }

      value(:id50) { Sai::Illuminant.load('illuminant/id50.yml', symbolize_names: true) }

      value(:id65) { Sai::Illuminant.load('illuminant/id65.yml', symbolize_names: true) }

      value(:led_b1) { Sai::Illuminant.load('illuminant/led_b1.yml', symbolize_names: true) }

      value(:led_b2) { Sai::Illuminant.load('illuminant/led_b2.yml', symbolize_names: true) }

      value(:led_b3) { Sai::Illuminant.load('illuminant/led_b3.yml', symbolize_names: true) }

      value(:led_b4) { Sai::Illuminant.load('illuminant/led_b4.yml', symbolize_names: true) }

      value(:led_b5) { Sai::Illuminant.load('illuminant/led_b5.yml', symbolize_names: true) }

      value(:led_bh1) { Sai::Illuminant.load('illuminant/led_bh1.yml', symbolize_names: true) }

      value(:led_rgb1) { Sai::Illuminant.load('illuminant/led_rgb1.yml', symbolize_names: true) }

      value(:led_v1) { Sai::Illuminant.load('illuminant/led_v1.yml', symbolize_names: true) }

      value(:led_v2) { Sai::Illuminant.load('illuminant/led_v2.yml', symbolize_names: true) }
    end
    # rubocop:enable Naming/VariableNumber
  end
end
