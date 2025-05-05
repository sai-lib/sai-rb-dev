# frozen_string_literal: true

module Sai
  module Formula
    module Distance
      module CIEDE2000
        CHROMA_WEIGHT_CONSTANT = 0.045
        COMPENSATION_DIVISOR = 25**7
        COMPENSATION_POWER = 7
        DEFAULT_VISUAL_THRESHOLD = 1.0
        DEGREE_RADIAN_CONVERSION = 180.0 / Math::PI
        EPSILON = 1e-6
        HUE_TERM_1_ANGLE = 30.0
        HUE_TERM_1_FACTOR = 0.17
        HUE_TERM_2_FACTOR = 0.24
        HUE_TERM_3_FACTOR = 0.32
        HUE_TERM_3_OFFSET = 6.0
        HUE_TERM_4_FACTOR = 0.20
        HUE_TERM_4_OFFSET = 63.0
        HUE_WEIGHT_CONSTANT = 0.015
        LIGHTNESS_COMPENSATION_DIVISOR = 20.0
        LIGHTNESS_COMPENSATION_OFFSET = 50.0
        LIGHTNESS_WEIGHT_CONSTANT = 0.015
        ROTATION_ANGLE = 275.0
        ROTATION_COMPENSATION = 2.0
        ROTATION_DIVISOR = 25.0
        ROTATION_FACTOR = 30.0

        class << self
          include TypeFacade

          def calculate(color1, color2, **options)
            [color1, color2].each do |color|
              next if color.is_a?(Space)

              raise TypeError, "color is invalid. Expected `Sai::Space`, got: #{color.inspect}"
            end

            color1 = color1.to_lab(**options)
            color2 = color2.to_lab(**options)

            Sai.cache.fetch(CIEDE2000, :calculate, color1.identity, color2.identity) do
              p_max = PERCENTAGE_RANGE.end
              l1, a1, b1 = color1.to_a.map { |channel| channel * p_max }
              l2, a2, b2 = color2.to_a.map { |channel| channel * p_max }

              c1 = Math.sqrt((a1 * a1) + (b1 * b1))
              c2 = Math.sqrt((a2 * a2) + (b2 * b2))
              c_avg = (c1 + c2) / 2.0

              g = 0.5 * (1 - Math.sqrt((c_avg**COMPENSATION_POWER) /
                                         ((c_avg**COMPENSATION_POWER) + COMPENSATION_DIVISOR)))

              a1_prime = (1 + g) * a1
              a2_prime = (1 + g) * a2

              c1_prime = Math.sqrt((a1_prime * a1_prime) + (b1 * b1))
              c2_prime = Math.sqrt((a2_prime * a2_prime) + (b2 * b2))

              h1_prime = calculate_hue_prime(a1_prime, b1)
              h2_prime = calculate_hue_prime(a2_prime, b2)

              delta_l_prime = l2 - l1
              delta_c_prime = c2_prime - c1_prime

              delta_h_prime = calculate_delta_h_prime(c1_prime, c2_prime, h1_prime, h2_prime)

              delta_h_term = 2 * Math.sqrt(c1_prime * c2_prime) *
                             Math.sin(delta_h_prime * Math::PI / DEGREE_RADIAN_CONVERSION / 2.0)

              l_prime_avg = (l1 + l2) / 2.0
              c_prime_avg = (c1_prime + c2_prime) / 2.0

              h_prime_avg = calculate_h_prime_avg(h1_prime, h2_prime, c1_prime, c2_prime)

              t = 1.0 - (HUE_TERM_1_FACTOR * Math.cos((h_prime_avg - HUE_TERM_1_ANGLE) *
                                                        Math::PI / DEGREE_RADIAN_CONVERSION)) +
                  (HUE_TERM_2_FACTOR * Math.cos((2.0 * h_prime_avg) *
                                                  Math::PI / DEGREE_RADIAN_CONVERSION)) +
                  (HUE_TERM_3_FACTOR * Math.cos(((3.0 * h_prime_avg) + HUE_TERM_3_OFFSET) *
                                                  Math::PI / DEGREE_RADIAN_CONVERSION)) -
                  (HUE_TERM_4_FACTOR * Math.cos(((4.0 * h_prime_avg) - HUE_TERM_4_OFFSET) *
                                                  Math::PI / DEGREE_RADIAN_CONVERSION))

              sl = 1.0 + ((LIGHTNESS_WEIGHT_CONSTANT * ((l_prime_avg - LIGHTNESS_COMPENSATION_OFFSET)**2)) /
                Math.sqrt(LIGHTNESS_COMPENSATION_DIVISOR + ((l_prime_avg - LIGHTNESS_COMPENSATION_OFFSET)**2)))
              sc = 1.0 + (CHROMA_WEIGHT_CONSTANT * c_prime_avg)
              sh = 1.0 + (HUE_WEIGHT_CONSTANT * c_prime_avg * t)

              theta = ROTATION_FACTOR * Math.exp(-((h_prime_avg - ROTATION_ANGLE) / ROTATION_DIVISOR)**2)
              rc = ROTATION_COMPENSATION * Math.sqrt((c_prime_avg**COMPENSATION_POWER) /
                                                       ((c_prime_avg**COMPENSATION_POWER) + COMPENSATION_DIVISOR))
              rt = -Math.sin(2.0 * theta * Math::PI / DEGREE_RADIAN_CONVERSION) * rc

              kl = kc = kh = 1.0

              delta_l_term = delta_l_prime / (kl * sl)
              delta_c_term = delta_c_prime / (kc * sc)
              delta_h_term /= (kh * sh)

              Math.sqrt(
                (delta_l_term**2) +
                  (delta_c_term**2) +
                  (delta_h_term**2) +
                  (rt * delta_c_term * delta_h_term),
              )
            end
          end

          private

          def calculate_delta_h_prime(c1_prime, c2_prime, h1_prime, h2_prime)
            return 0.0 if c1_prime.abs < EPSILON || c2_prime.abs < EPSILON

            delta_h = h2_prime - h1_prime

            if delta_h.abs > 180.0
              delta_h += delta_h > 0.0 ? -360.0 : 360.0
            end

            delta_h
          end

          def calculate_h_prime_avg(h1_prime, h2_prime, c1_prime, c2_prime)
            return h1_prime + h2_prime if c1_prime.abs < EPSILON || c2_prime.abs < EPSILON

            h_diff = (h1_prime - h2_prime).abs

            if h_diff <= 180.0
              h_avg = (h1_prime + h2_prime) / 2.0
            else
              h_avg = (h1_prime + h2_prime + 360.0) / 2.0
              h_avg -= 360.0 if h_avg > 360.0
            end

            h_avg
          end

          def calculate_hue_prime(a_prime, b)
            return 0.0 if a_prime.abs < EPSILON && b.abs < EPSILON

            h_prime = Math.atan2(b, a_prime) * DEGREE_RADIAN_CONVERSION
            h_prime += 360.0 if h_prime < 0.0

            h_prime
          end
        end
      end
    end
  end
end
