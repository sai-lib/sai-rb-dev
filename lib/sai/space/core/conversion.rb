# frozen_string_literal: true

module Sai
  module Space
    module Core
      module Conversion
        class << self
          private

          def included(base)
            super

            base.include Sai::Core::Concurrency
            base.include BasicInstanceMethods
            base.include EncodedInstanceMethods
            base.include PerceptualInstanceMethods
            base.include PhysiologicalInstanceMethods
          end
        end

        module BasicInstanceMethods
          def to_array
            components.to_normalized
          end
          alias serialize to_array
          alias to_a      to_array

          def to_css
            hexadecimal
          end

          def to_greyscale(**options)
            coerce(Sai.config.default_rgb_space.from_fraction(luminance, luminance, luminance, **options))
          end
          alias to_grayscale to_greyscale

          def to_string
            if opacity < PERCENTAGE_RANGE.end
              "#{identifier}a(#{components.to_string}, #{opacity.round(2)}%)"
            else
              "#{identifier}(#{components.to_string})"
            end
          end
          alias to_s to_string

          private

          def conversions
            concurrent_instance_variable_fetch(:@conversions, EMPTY_HASH)
          end

          def convert_to(space, normalized: true, map_to_gamut: false, **options)
            cache_enabled = Sai.config.conversion_caching_enabled?
            context_attributes = Space::Context.attribute_names
            context = space.native_context.nil? ? local_context : space.native_context

            components = if cache_enabled && conversions.key?(space.identifier)
                           conversions[space.identifier]
                         else
                           Sai.cache.fetch(self.class, :"to_#{space.identifier}", identity) { yield(context) }
                         end

            if cache_enabled && !conversions.key?(space.identifier)
              new_conversions = conversions.merge(space.identifier => components).freeze
              mutex.synchronize { @conversions = new_conversions }
            end

            result = space.from_intermediate(
              *components, normalized:, **options.except(*context_attributes), **context.to_h
            )

            if context_attributes.any? { |k| options.key?(k) }
              result = result.with_context(**options.slice(*context_attributes))
            end

            result = result.map_to_gamut if map_to_gamut
            result = result.with_opacity(opacity)

            if cache_enabled
              new_conversions = result.send(:conversions).merge(**conversions).merge(identifier => to_a).freeze
              result.send(:mutex).synchronize { result.instance_variable_set(:@conversions, new_conversions) }
            end

            result
          end

          def convert_to_self(**options)
            context_attributes = Space::Context.attribute_names
            return self unless context_attributes.any? { |k| options.key?(k) }

            convert_to(self.class, **options) { to_a }
          end
        end

        module EncodedInstanceMethods
          class << self
            private

            def included(base)
              super

              base.include RGB
            end
          end

          module RGB
            def to_aces_cg_rgb(**options)
              to_rgb(rgb_space: Sai::Space::Encoded::RGB::AcesCG, map_to_gamut: true, **options)
            end

            def to_aces_rgb(**options)
              to_rgb(rgb_space: Sai::Space::Encoded::RGB::Aces, map_to_gamut: true, **options)
            end

            def to_adobe_rgb(**options)
              to_rgb(rgb_space: Sai::Space::Encoded::RGB::Adobe1998, map_to_gamut: true, **options)
            end

            def to_alexa_wide_gamut_rgb(**options)
              to_rgb(rgb_space: Sai::Space::Encoded::RGB::AlexaWideGamut, map_to_gamut: true, **options)
            end

            def to_apple_rgb(**options)
              to_rgb(rgb_space: Sai::Space::Encoded::RGB::Apple, map_to_gamut: true, **options)
            end

            def to_best_rgb(**options)
              to_rgb(rgb_space: Sai::Space::Encoded::RGB::Best, map_to_gamut: true, **options)
            end

            def to_beta_rgb(**options)
              to_rgb(rgb_space: Sai::Space::Encoded::RGB::Beta, map_to_gamut: true, **options)
            end

            def to_bruce_rgb(**options)
              to_rgb(rgb_space: Sai::Space::Encoded::RGB::Bruce, map_to_gamut: true, **options)
            end

            def to_cie_rgb(**options)
              to_rgb(rgb_space: Sai::Space::Encoded::RGB::CIE, map_to_gamut: true, **options)
            end

            def to_color_match_rgb(**options)
              to_rgb(rgb_space: Sai::Space::Encoded::RGB::ColorMatch, map_to_gamut: true, **options)
            end

            def to_dci_p3_rgb(**options)
              to_rgb(rgb_space: Sai::Space::Encoded::RGB::DCIP3, map_to_gamut: true, **options)
            end

            def to_display_p3_rgb(**options)
              to_rgb(rgb_space: Sai::Space::Encoded::RGB::DisplayP3, map_to_gamut: true, **options)
            end

            def to_don_rgb_4(**options)
              to_rgb(rgb_space: Sai::Space::Encoded::RGB::Don4, map_to_gamut: true, **options)
            end

            def to_eci_rgb(**options)
              to_rgb(rgb_space: Sai::Space::Encoded::RGB::ECI, map_to_gamut: true, **options)
            end

            def to_ekta_space_ps5_rgb(**options)
              to_rgb(rgb_space: Sai::Space::Encoded::RGB::EktaSpacePS5, map_to_gamut: true, **options)
            end

            def to_ntsc_rgb(**options)
              to_rgb(rgb_space: Sai::Space::Encoded::RGB::NTSC, map_to_gamut: true, **options)
            end

            def to_pal_secam_rgb(**options)
              to_rgb(rgb_space: Sai::Space::Encoded::RGB::PALSecam, map_to_gamut: true, **options)
            end

            def to_pro_photo_rgb(**options)
              to_rgb(rgb_space: Sai::Space::Encoded::RGB::ProPhoto, map_to_gamut: true, **options)
            end

            def to_rec2020_rgb(**options)
              to_rgb(rgb_space: Sai::Space::Encoded::RGB::Rec2020, map_to_gamut: true, **options)
            end

            def to_rec709_rgb(**options)
              to_rgb(rgb_space: Sai::Space::Encoded::RGB::Rec709, map_to_gamut: true, **options)
            end

            def to_rimm_rgb(**options)
              to_rgb(rgb_space: Sai::Space::Encoded::RGB::RIMM, map_to_gamut: true, **options)
            end

            def to_s_gamut3_cine_rgb(**options)
              to_rgb(rgb_space: Sai::Space::Encoded::RGB::SGamut3Cine, map_to_gamut: true, **options)
            end

            def to_s_gamut3_rgb(**options)
              to_rgb(rgb_space: Sai::Space::Encoded::RGB::SGamut3, map_to_gamut: true, **options)
            end

            def to_smpte_c_rgb(**options)
              to_rgb(rgb_space: Sai::Space::Encoded::RGB::SMPTEC, map_to_gamut: true, **options)
            end

            def to_srgb(**options)
              to_rgb(rgb_space: Sai::Space::Encoded::RGB::Standard, map_to_gamut: true, **options)
            end

            def to_wide_gamut_rgb(**options)
              to_rgb(rgb_space: Sai::Space::Encoded::RGB::WideGamut, map_to_gamut: true, **options)
            end
          end

          def to_cmy(...)
            to_rgb(...).to_cmy(...)
          end

          def to_cmyk(...)
            to_rgb(...).to_cmyk(...)
          end

          def to_hsb(...)
            to_rgb(...).to_hsb(...)
          end

          def to_hsl(...)
            to_rgb(...).to_hsl(...)
          end

          def to_hsv(...)
            to_rgb(...).to_hsv(...)
          end

          def to_hwb(...)
            to_rgb(...).to_hwb(...)
          end

          def to_okhsl(...)
            to_oklab(...).to_okhsl(...)
          end

          def to_okhsv(...)
            to_oklab(...).to_okhsv(...)
          end

          def to_rgb(rgb_space: Sai.config.default_rgb_space, **options)
            to_xyz(**options).to_rgb(rgb_space:, map_to_gamut: true, **options)
          end
        end

        module PerceptualInstanceMethods
          def to_hunter_lab(...)
            to_xyz(...).to_hunter_lab(...)
          end

          def to_lab_d50(...)
            to_xyz(...).to_lab_d50(...)
          end
          alias to_lab to_lab_d50

          def to_lab_d65(...)
            to_xyz(...).to_lab_d65(...)
          end

          def to_lch_d50(...)
            to_lab_d50(...).to_lch_d50(...)
          end
          alias to_lch to_lch_d50

          def to_lch_d65(...)
            to_lab_d65(...).to_lch_d65(...)
          end

          def to_luv(...)
            to_xyz(...).to_luv(...)
          end

          def to_oklab(...)
            to_xyz(...).to_oklab(...)
          end

          def to_oklch(...)
            to_oklab(...).to_oklch(...)
          end
        end

        module PhysiologicalInstanceMethods
          def to_lms(...)
            to_xyz(...).to_lms(...)
          end

          def to_xyz(...)
            raise NoMethodError, "undefined method `to_xyz` for #{self}"
          end
        end
      end
    end
  end
end
