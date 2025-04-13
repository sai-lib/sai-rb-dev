# frozen_string_literal: true

module Sai
  module Formula
    module Distance
      module CIECMC
        CHROMA_CONSTANT = 6.380e-01
        CHROMA_FACTOR = 1.0
        CHROMA_FACTOR_1 = 6.380e-02
        CHROMA_FACTOR_2 = 1.310e-02
        DEFAULT_VISUAL_THRESHOLD = 1.5
        DEGREE_RADIAN_CONVERSION = 180 / Math::PI
        F_FACTOR_DIVISOR = 1900.0
        HIGH_HUE_AMPLITUDE = 0.2
        HIGH_HUE_BASE = 0.56
        HIGH_HUE_PHASE = 168.0
        HUE_LOWER_THRESHOLD = 164.0
        HUE_UPPER_THRESHOLD = 345.0
        LIGHT_FACTOR = 2.0
        LOW_HUE_AMPLITUDE = 0.4
        LOW_HUE_BASE = 0.36
        LOW_HUE_PHASE = 35.0
        LOW_LUMINANCE_SL = 0.511
        LOW_LUMINANCE_THRESHOLD = 16.0
        LUMINANCE_FACTOR_1 = 4.098e-02
        LUMINANCE_FACTOR_2 = 1.765e-02

        class << self
          def calculate(color1, color2, **options)
            [color1, color2].each do |color|
              next if color.is_a?(Model)

              raise TypeError, "color is invalid. Expected `Sai::Model`, got: #{color.inspect}"
            end

            color1 = color1.to_lab(**options)
            color2 = color2.to_lab(**options)

            p_max = PERCENTAGE_RANGE.end
            l1, a1, b1 = color1.to_n_a.map { |channel| channel * p_max }
            l2, a2, b2 = color2.to_n_a.map { |channel| channel * p_max }

            c1 = Math.sqrt((a1**2) + (b1**2))
            c2 = Math.sqrt((a2**2) + (b2**2))

            h1 = Math.atan2(b1, a1) * DEGREE_RADIAN_CONVERSION
            h1 += 360 if h1.negative?

            delta_l = l2 - l1
            delta_c = c2 - c1

            delta_a = a2 - a1
            delta_b = b2 - b1
            delta_h_squared = (delta_a**2) + (delta_b**2) - (delta_c**2)
            delta_h_squared = 0 if delta_h_squared.negative?
            delta_h = Math.sqrt(delta_h_squared)

            sl = if l1 < LOW_LUMINANCE_THRESHOLD
                   LOW_LUMINANCE_SL
                 else
                   (LUMINANCE_FACTOR_1 * l1) / (1 + (LUMINANCE_FACTOR_2 * l1))
                 end
            sc = ((CHROMA_FACTOR_1 * c1) / (1 + (CHROMA_FACTOR_2 * c1))) + CHROMA_CONSTANT

            f = Math.sqrt((c1**4) / ((c1**4) + F_FACTOR_DIVISOR))
            t = if h1.between?(HUE_LOWER_THRESHOLD, HUE_UPPER_THRESHOLD)
                  HIGH_HUE_BASE + Math.abs(HIGH_HUE_AMPLITUDE *
                                             Math.cos((h1 + HIGH_HUE_PHASE) * Math::PI / DEGREE_RADIAN_CONVERSION))
                else
                  LOW_HUE_BASE + Math.abs(LOW_HUE_AMPLITUDE *
                                            Math.cos((h1 + LOW_HUE_PHASE) * Math::PI / DEGREE_RADIAN_CONVERSION))
                end
            sh = sc * ((f * t) + 1 - f)

            term1 = (delta_l / (LIGHT_FACTOR * sl))**2
            term2 = (delta_c / (CHROMA_FACTOR * sc))**2
            term3 = (delta_h / sh)**2

            Math.sqrt(term1 + term2 + term3)
          end
        end
      end
    end
  end
end
