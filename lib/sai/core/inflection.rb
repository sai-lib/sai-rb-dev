# frozen_string_literal: true

module Sai
  module Core
    module Inflection
      ACRONYMS = EMPTY_ARRAY
      private_constant :ACRONYMS

      class << self
        def pascal_case(string)
          string.to_s.split('_').map do |segment|
            ACRONYMS.include?(segment.upcase) ? segment.upcase : segment.capitalize
          end.join
        end

        def snake_case(string)
          string.to_s.gsub(/([A-Z]+)([A-Z][a-z])/, '\\1_\\2').gsub(/([a-z\d])([A-Z])/, '\\1_\\2').downcase
        end
      end
    end
  end
end
