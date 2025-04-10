# frozen_string_literal: true

module Sai
  module Enum
    module ColorSpace
      extend Enum

      module Category
        extend Enum

        value(:broadcast) { :broadcast }

        value(:cinema) { :cinema }

        value(:design) { :design }

        value(:display) { :display }

        value(:photography) { :photography }

        value(:printing) { :printing }

        value(:reference) { :reference }
      end

      module GammaStrategy
        extend Enum

        value(:linear) { :linear }

        value(:transfer_function) { :transfer_function }
      end

      value(:aces) { Sai::Space.load('color_space/aces.yml', symbolize_names: true) }

      value(:aces_cg) { Sai::Space.load('color_space/aces_cg.yml', symbolize_names: true) }

      value(:adobe_rgb1998) { Sai::Space.load('color_space/adobe_rgb1998.yml', symbolize_names: true) }

      value(:alexa_wide_gamut) { Sai::Space.load('color_space/alexa_wide_gamut.yml', symbolize_names: true) }

      value(:apple_rgb) { Sai::Space.load('color_space/apple_rgb.yml', symbolize_names: true) }

      value(:best_rgb) { Sai::Space.load('color_space/best_rgb.yml', symbolize_names: true) }

      value(:beta_rgb) { Sai::Space.load('color_space/beta_rgb.yml', symbolize_names: true) }

      value(:bruce_rgb) { Sai::Space.load('color_space/bruce_rgb.yml', symbolize_names: true) }

      value(:cie_rgb) { Sai::Space.load('color_space/cie_rgb.yml', symbolize_names: true) }

      value(:color_match_rgb) { Sai::Space.load('color_space/color_match_rgb.yml', symbolize_names: true) }

      value(:dci_p3) { Sai::Space.load('color_space/dci_p3.yml', symbolize_names: true) }

      value(:display_p3) { Sai::Space.load('color_space/display_p3.yml', symbolize_names: true) }

      value(:don_rgb4) { Sai::Space.load('color_space/don_rgb4.yml', symbolize_names: true) }

      value(:eci_rgb) { Sai::Space.load('color_space/eci_rgb.yml', symbolize_names: true) }

      value(:ekta_space_ps5) { Sai::Space.load('color_space/ekta_space_ps5.yml', symbolize_names: true) }

      value(:ntsc_rgb) { Sai::Space.load('color_space/ntsc_rgb.yml', symbolize_names: true) }

      value(:pal_secam_rgb) { Sai::Space.load('color_space/pal_secam_rgb.yml', symbolize_names: true) }

      value(:pro_photo_rgb) { Sai::Space.load('color_space/pro_photo_rgb.yml', symbolize_names: true) }

      value(:rec709) { Sai::Space.load('color_space/rec709.yml', symbolize_names: true) }

      value(:rec2020) { Sai::Space.load('color_space/rec2020.yml', symbolize_names: true) }

      value(:rimm_rgb) { Sai::Space.load('color_space/rimm_rgb.yml', symbolize_names: true) }

      value(:s_gamut3) { Sai::Space.load('color_space/s_gamut3.yml', symbolize_names: true) }

      value(:s_gamut3_cine) { Sai::Space.load('color_space/s_gamut3_cine.yml', symbolize_names: true) }

      value(:smpte_c_rgb) { Sai::Space.load('color_space/smpte_c_rgb.yml', symbolize_names: true) }

      value(:srgb) { Sai::Space.load('color_space/srgb.yml', symbolize_names: true) }

      value(:wide_gamut_rgb) { Sai::Space.load('color_space/wide_gamut_rgb.yml', symbolize_names: true) }
    end
  end
end
