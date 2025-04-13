# frozen_string_literal: true

module Sai
  module Formula
    module Distance
      module CIE94
        CHROMA_FACTOR = 1.0
        DEFAULT_VISUAL_THRESHOLD = 1.0
        GRAPHIC_ARTS_SCALING_CHROMA = 4.500e-02
        GRAPHIC_ARTS_SCALING_HUE = 1.500e-02
        HUE_FACTOR = 1.0
        LIGHT_FACTOR = 1.0
        TEXTILE_SCALING_CHROMA = 4.800e-02
        TEXTILE_SCALING_HUE = 1.400e-02

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

            k1, k2 = application_constants(options.fetch(:application, Sai.config.distance_application.resolve))

            c1 = Math.sqrt((a1**2) + (b1**2))
            c2 = Math.sqrt((a2**2) + (b2**2))

            delta_l = l1 - l2
            delta_c = c1 - c2

            delta_a = a1 - a2
            delta_b = b1 - b2
            delta_h_squared = (delta_a**2) + (delta_b**2) - (delta_c**2)
            delta_h_squared = 0 if delta_h_squared.negative?

            sl = 1.0
            sc = 1.0 + (k1 * c1)
            sh = 1.0 + (k2 * c1)

            term1 = (delta_l / (LIGHT_FACTOR * sl))**2
            term2 = (delta_c / (CHROMA_FACTOR * sc))**2
            term3 = Math.sqrt(delta_h_squared) / (HUE_FACTOR * sh)
            term3 **= 2

            Math.sqrt(term1 + term2 + term3)
          end

          private

          def application_constants(application)
            case application
            when Sai::Enum::Formula::Distance::Application::GRAPHIC_ARTS
              [GRAPHIC_ARTS_SCALING_CHROMA, GRAPHIC_ARTS_SCALING_HUE].freeze
            when Sai::Enum::Formula::Distance::Application::TEXTILE
              [TEXTILE_SCALING_CHROMA, TEXTILE_SCALING_HUE].freeze
            else
              raise ArgumentError, '`:application` is invalid. Expected one of ' \
                                   "#{Sai::Enum::Formula::Distance::Application.resolve_all.join(', ')}, " \
                                   "got: #{application.inspect}"
            end
          end
        end
      end
    end
  end
end
