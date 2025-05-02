# frozen_string_literal: true

module Sai
  module Space
    module Encoded
      class RGB
        module GammaStrategy
          LINEAR            = :linear
          TRANSFER_FUNCTION = :transfer_function

          ALL = [LINEAR, TRANSFER_FUNCTION].freeze
        end
      end
    end
  end
end
