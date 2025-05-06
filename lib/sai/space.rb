# frozen_string_literal: true

module Sai
  module Space
    autoload :Base,          'sai/space/base'
    autoload :Context,       'sai/space/context'
    autoload :Core,          'sai/space/core'
    autoload :Encoded,       'sai/space/encoded'
    autoload :Gamut,         'sai/space/gamut'
    autoload :MixStrategy,   'sai/space/mix_strategy'
    autoload :Perceptual,    'sai/space/perceptual'
    autoload :Physiological, 'sai/space/physiological'
    autoload :TypeFacade,    'sai/space/type_facade'

    extend TypeFacade
  end
end
