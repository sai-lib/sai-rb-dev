# frozen_string_literal: true

module Sai
  module Inflection
    module CaseRefinements
      refine String do
        def to_pascal_case
          split('_').map do |segment|
            Inflection::ACRONYMS.include?(segment.upcase) ? segment.upcase : segment.capitalize
          end.join
        end

        def to_snake_case
          gsub(/([A-Z]+)([A-Z][a-z])/, '\\1_\\2').gsub(/([a-z\d])([A-Z])/, '\\1_\\2').downcase
        end
      end

      refine Symbol do
        def to_pascal_case
          to_s.to_pascal_case.to_sym
        end

        def to_snake_case
          to_s.to_snake_case.to_sym
        end
      end
    end
  end
end
