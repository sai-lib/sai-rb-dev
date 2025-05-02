# frozen_string_literal: true

module Sai
  module Space
    module Perceptual
      autoload :Base,      'sai/space/perceptual/base'
      autoload :HunterLab, 'sai/space/perceptual/hunter_lab'
      autoload :Lab,       'sai/space/perceptual/lab'
      autoload :LCh,       'sai/space/perceptual/l_ch'
      autoload :Luv,       'sai/space/perceptual/luv'
      autoload :Oklab,     'sai/space/perceptual/oklab'
      autoload :Oklch,     'sai/space/perceptual/oklch'

      extend TypeFacade
    end
  end
end
