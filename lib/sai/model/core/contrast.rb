# frozen_string_literal: true

module Sai
  class Model
    module Core
      module Contrast
        def contrast_ratio(other, **options)
          formula = Enum.resolve(options.fetch(:formula, Sai.config.default_contrast_formula))

          unless formula.name.start_with?(Sai::Formula::Contrast.name)
            raise TypeError,
                  "`:formula` is invalid. Expected `Sai::Contrast`, got: #{formula.inspect}"
          end

          formula.calculate(self, coerce(other), **options)
        end

        def luminance
          @luminance ||= begin
            linear_rgb = to_n_a.map { |channel| encoding_specification.color_space.gamma.to_linear(channel) }
            bt709 = Formula::Contrast::BT709
            (bt709::RED_COEFFICIENT * linear_rgb[0]) + (bt709::GREEN_COEFFICIENT * linear_rgb[1]) +
              (bt709::BLUE_COEFFICIENT * linear_rgb[2])
          end
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
          contrast_ratio = contrast_ratio(
            coerce(background_color),
            **options,
            formula: Formula::Contrast::APCA,
          )
          contrast_ratio.abs >= threshold
        end

        def sufficient_wcag_contrast?(background_color, **options)
          threshold = options.fetch(:threshold)
          contrast_ratio = contrast_ratio(
            coerce(background_color),
            **options,
            formula: Formula::Contrast::WCAG,
          )
          contrast_ratio >= threshold
        end
      end
    end
  end
end
