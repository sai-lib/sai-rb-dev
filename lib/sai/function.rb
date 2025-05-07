# frozen_string_literal: true

module Sai
  module Function
    class << self
      private

      def extended(base)
        super

        base.extend Encoded
        base.extend Perceptual
        base.extend Physiological
      end

      def included(base)
        super

        base.include Encoded
        base.include Perceptual
        base.include Physiological
      end
    end

    module Encoded
      class << self
        private

        def extended(base)
          super

          base.extend RGB
        end

        def included(base)
          super

          base.include RGB
        end
      end

      module RGB
        def aces_cg_rgb(*components, **options)
          rgb(*components, rgb_space: Space::Encoded::RGB::AcesCG, **options)
        end

        def aces_rgb(*components, **options)
          rgb(*components, rgb_space: Space::Encoded::RGB::Aces, **options)
        end

        def adobe_rgb(*components, **options)
          rgb(*components, rgb_space: Space::Encoded::RGB::Adobe1998, **options)
        end

        def alexa_wide_gamut_rgb(*components, **options)
          rgb(*components, rgb_space: Space::Encoded::RGB::AlexaWideGamut, **options)
        end

        def apple_rgb(*components, **options)
          rgb(*components, rgb_space: Space::Encoded::RGB::Apple, **options)
        end

        def best_rgb(*components, **options)
          rgb(*components, rgb_space: Space::Encoded::RGB::Best, **options)
        end

        def beta_rgb(*components, **options)
          rgb(*components, rgb_space: Space::Encoded::RGB::Beta, **options)
        end

        def bruce_rgb(*components, **options)
          rgb(*components, rgb_space: Space::Encoded::RGB::Bruce, **options)
        end

        def cie_rgb(*components, **options)
          rgb(*components, rgb_space: Space::Encoded::RGB::CIE, **options)
        end

        def color_match_rgb(*components, **options)
          rgb(*components, rgb_space: Space::Encoded::RGB::ColorMatch, **options)
        end

        def dci_p3_rgb(*components, **options)
          rgb(*components, rgb_space: Space::Encoded::RGB::DCIP3, **options)
        end

        def display_p3_rgb(*components, **options)
          rgb(*components, rgb_space: Space::Encoded::RGB::DisplayP3, **options)
        end

        def don_rgb_4(*components, **options)
          rgb(*components, rgb_space: Space::Encoded::RGB::Don4, **options)
        end

        def eci_rgb(*components, **options)
          rgb(*components, rgb_space: Space::Encoded::RGB::ECI, **options)
        end

        def ekta_space_ps5_rgb(*components, **options)
          rgb(*components, rgb_space: Space::Encoded::RGB::EktaSpacePS5, **options)
        end

        def ntsc_rgb(*components, **options)
          rgb(*components, rgb_space: Space::Encoded::RGB::NTSC, **options)
        end

        def pal_secam_rgb(*components, **options)
          rgb(*components, rgb_space: Space::Encoded::RGB::PALSecam, **options)
        end

        def pro_photo_rgb(*components, **options)
          rgb(*components, rgb_space: Space::Encoded::RGB::ProPhoto, **options)
        end

        def rec2020_rgb(*components, **options)
          rgb(*components, rgb_space: Space::Encoded::RGB::Rec2020, **options)
        end

        def rec709_rgb(*components, **options)
          rgb(*components, rgb_space: Space::Encoded::RGB::Rec709, **options)
        end

        def rimm_rgb(*components, **options)
          rgb(*components, rgb_space: Space::Encoded::RGB::RIMM, **options)
        end

        def s_gamut3_cine_rgb(*components, **options)
          rgb(*components, rgb_space: Space::Encoded::RGB::SGamut3Cine, **options)
        end

        def s_gamut3_rgb(*components, **options)
          rgb(*components, rgb_space: Space::Encoded::RGB::SGamut3, **options)
        end

        def smpte_c_rgb(*components, **options)
          rgb(*components, rgb_space: Space::Encoded::RGB::SMPTEC, **options)
        end

        def srgb(*components, **options)
          rgb(*components, rgb_space: Space::Encoded::RGB::Standard, **options)
        end

        def wide_gamut_rgb(*components, **options)
          rgb(*components, rgb_space: Space::Encoded::RGB::WideGamut, **options)
        end
      end

      def cmy(...)
        Space::Encoded::CMY.new(...)
      end

      def cmyk(...)
        Space::Encoded::CMYK.new(...)
      end

      def hsb(...)
        Space::Encoded::HSB.new(...)
      end

      def hsl(...)
        Space::Encoded::HSL.new(...)
      end

      def hsv(...)
        Space::Encoded::HSV.new(...)
      end

      def hwb(...)
        Space::Encoded::HWB.new(...)
      end

      def rgb(*components, **options)
        rgb_space = options.fetch(:rgb_space, options.fetch(:space, Sai.config.default_rgb_space))
        rgb_space.new(*components, **options)
      end
    end

    module Perceptual
      def hunter_lab(...)
        Space::Perceptual::HunterLab.new(...)
      end

      def lab_d50(...)
        Space::Perceptual::Lab::D50.new(...)
      end
      alias lab lab_d50

      def lab_d65(...)
        Space::Perceptual::Lab::D65.new(...)
      end

      def lch_d50(...)
        Space::Perceptual::LCh::D50.new(...)
      end
      alias lch lch_d50

      def lch_d65(...)
        Space::Perceptual::LCh::D65.new(...)
      end

      def luv(...)
        Space::Perceptual::Luv.new(...)
      end

      def okhsl(...)
        Space::Perceptual::Okhsl.new(...)
      end

      def okhsv(...)
        Space::Perceptual::Okhsv.new(...)
      end

      def oklab(...)
        Space::Perceptual::Oklab.new(...)
      end

      def oklch(...)
        Space::Perceptual::Oklch.new(...)
      end
    end

    module Physiological
      def lms(...)
        Space::Physiological::LMS.new(...)
      end

      def xyz(...)
        Space::Physiological::XYZ.new(...)
      end
    end
  end
end
