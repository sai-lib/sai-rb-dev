# frozen_string_literal: true

module Sai
  module Space
    module Core
      module Contrast
        class << self
          private

          def included(base)
            super

            base.include InstanceMethods
          end
        end

        module InstanceMethods
          def contrast_ratio_with(other, **options)
            formula = options.fetch(:formula, Sai.config.default_contrast_formula)

            unless formula.is_a?(Sai::Formula::Contrast)
              raise TypeError, "`:formula` is invalid. Expected `Sai::Contrast`, got: #{formula.inspect}"
            end

            formula.calculate(self, other, **options)
          end

          def dark?(threshold = 0.5)
            luminance < threshold
          end

          def light?(threshold = 0.5)
            luminance >= threshold
          end

          def sufficient_contrast_for_aa?(background_color, **options)
            sufficient_wcag_contrast?(
              background_color,
              threshold: Formula::Contrast::WCAG::DEFAULT_AA_THRESHOLD,
              **options,
            )
          end

          def sufficient_contrast_for_aa_large?(background_color, **options)
            sufficient_wcag_contrast?(
              background_color,
              threshold: Formula::Contrast::WCAG::DEFAULT_AA_LARGE_THRESHOLD,
              **options,
            )
          end

          def sufficient_contrast_for_aaa?(background_color, **options)
            sufficient_wcag_contrast?(
              background_color,
              threshold: Formula::Contrast::WCAG::DEFAULT_AAA_THRESHOLD,
              **options,
            )
          end

          def sufficient_contrast_for_aaa_large?(background_color, **options)
            sufficient_wcag_contrast?(
              background_color,
              threshold: Formula::Contrast::WCAG::DEFAULT_AAA_LARGE_THRESHOLD,
              **options,
            )
          end

          def sufficient_contrast_for_body_text?(background_color, **options)
            sufficient_apca_contrast?(
              background_color,
              threshold: Formula::Contrast::APCA::DEFAULT_BODY_TEXT_THRESHOLD,
              **options,
            )
          end

          def sufficient_contrast_for_large_text?(background_color, **options)
            sufficient_apca_contrast?(
              background_color,
              threshold: Formula::Contrast::APCA::DEFAULT_LARGE_TEXT_THRESHOLD,
              **options,
            )
          end

          def sufficient_contrast_for_very_large_text?(background_color, **options)
            sufficient_apca_contrast?(
              background_color,
              threshold: Formula::Contrast::APCA::DEFAULT_VERY_LARGE_TEXT_THRESHOLD,
              **options,
            )
          end

          private

          def sufficient_apca_contrast?(background_color, **options)
            threshold = options.fetch(:threshold)
            contrast_ratio = contrast_ratio(background_color, **options, formula: Formula::Contrast::APCA)
            contrast_ratio.abs >= threshold
          end

          def sufficient_wcag_contrast?(background_color, **options)
            threshold = options.fetch(:threshold)
            contrast_ratio = contrast_ratio(background_color, **options, formula: Formula::Contrast::WCAG)
            contrast_ratio >= threshold
          end
        end
      end
    end
  end
end
