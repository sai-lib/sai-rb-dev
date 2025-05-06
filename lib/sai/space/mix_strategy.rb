# frozen_string_literal: true

module Sai
  module Space
    module MixStrategy
      CIRCULAR_HUE          = :circular_hue
      GAMMA_CORRECTED       = :gamma_corrected
      LINEAR                = :linear
      PERCEPTUALLY_UNIFORM  = :perceptually_uniform
      PERCEPTUALLY_WEIGHTED = :perceptually_weighted

      ALL = [
        CIRCULAR_HUE,
        GAMMA_CORRECTED,
        LINEAR,
        PERCEPTUALLY_UNIFORM,
        PERCEPTUALLY_WEIGHTED,
      ].freeze
    end
  end
end
