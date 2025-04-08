# frozen_string_literal: true

module Sai
  class Model
    module Core
      module Introspection
        class << self
          private

          def included(base)
            super

            base.extend ClassMethods
          end
        end

        module ClassMethods
          using Inflection::CaseRefinements

          def symbol
            @symbol ||= name.split('::').last.to_snake_case.to_sym
          end
        end

        def hash
          to_n_a.hash
        end

        def symbol
          @symbol ||= self.class.symbol
        end

        def to_array
          model = with_opacity_flattened
          self.class.channels.map { |channel| model.instance_variable_get(:"@#{channel.symbol}") }
        end
        alias to_a to_array

        def to_normalized_array
          to_array.map(&:normalized)
        end
        alias to_n_a to_normalized_array

        def to_string
          display_symbol = symbol

          channels = self.class.channels.map { |channel| instance_variable_get(:"@#{channel.symbol}").to_s }

          if opacity < PERCENTAGE_RANGE.end
            channels << format('%.1f%%', opacity)
            display_symbol = "#{display_symbol}a"
          end

          "#{display_symbol}(#{channels.join(', ')})".freeze
        end
        alias inspect to_string
        alias to_s    to_string

        def to_unnormalized_array
          to_array.map(&:unnormalized)
        end
        alias to_un_a to_unnormalized_array
      end
    end
  end
end
