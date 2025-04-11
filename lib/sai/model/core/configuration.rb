# frozen_string_literal: true

module Sai
  class Model
    module Core
      module Configuration
        def encoding_specification(**options)
          build_encoding_specification_from_options(**options) || default_encoding_specification
        end

        private

        def build_encoding_specification_from_options(**options)
          if options.key?(:color_space)
            EncodingSpecification.new(**options)
          elsif options.key?(:encoding_specification)
            encoding_specification = options[:encoding_specification]
            unless encoding_specification.is_a?(EncodingSpecification)
              raise TypeError, '`:encoding_specification` is invalid. Expected `EncodingSpecification`, ' \
                               "got: #{encoding_specification.inspect}"
            end

            encoding_specification
          end
        end

        def default_encoding_specification
          @default_encoding_specification ||=
            build_encoding_specification_from_options(**@config) || EncodingSpecification.new
        end

        def initialize_configuration(**options)
          @config = options.slice(
            :cat,
            :chromatic_adaptation_transform,
            :color_space,
            :encoding_specification,
            :illuminant,
            :observer,
            :viewing_condition,
          )
        end
      end
    end
  end
end
