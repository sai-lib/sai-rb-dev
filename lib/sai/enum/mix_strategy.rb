# frozen_string_literal: true

module Sai
  module Enum
    module MixStrategy
      extend Enum

      value(:circular_hue) { :circular_hue }

      value(:gamut_aware) { :gamut_aware }

      value(:gamma_corrected) { :gamma_corrected }

      value(:linear) { :linear }

      value(:perceptually_uniform) { :perceptually_uniform }

      value(:perceptually_weighted) { :perceptually_weighted }
    end
  end
end
