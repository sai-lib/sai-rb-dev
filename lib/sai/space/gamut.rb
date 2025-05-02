# frozen_string_literal: true

module Sai
  module Space
    module Gamut
      module Mapping
        CLIP       = :clip
        COMPRESS   = :compress
        PERCEPTUAL = :perceptual
        SCALE      = :scale

        ALL = [CLIP, COMPRESS, PERCEPTUAL, SCALE].freeze
      end
    end
  end
end
