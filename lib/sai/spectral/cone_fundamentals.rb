# frozen_string_literal: true

module Sai
  module Spectral
    class ConeFundamentals < Table
      with_responses ConeResponse

      coerce_responses_with do |data|
        data.transform_values do |value|
          value.is_a?(ConeResponse) ? value : ConeResponse.new(*value)
        end
      end
    end
  end
end
