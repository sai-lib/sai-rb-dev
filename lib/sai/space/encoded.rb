# frozen_string_literal: true

module Sai
  module Space
    module Encoded
      autoload :Base,  'sai/space/encoded/base'
      autoload :CMY,   'sai/space/encoded/cmy'
      autoload :CMYK,  'sai/space/encoded/cmyk'
      autoload :HSB,   'sai/space/encoded/hsb'
      autoload :HSL,   'sai/space/encoded/hsl'
      autoload :HSV,   'sai/space/encoded/hsv'
      autoload :HWB,   'sai/space/encoded/hwb'
      autoload :Okhsl, 'sai/space/encoded/okhsl'
      autoload :Okhsv, 'sai/space/encoded/okhsv'
      autoload :RGB,   'sai/space/encoded/rgb'

      extend TypeFacade
    end
  end
end
