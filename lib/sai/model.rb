# frozen_string_literal: true

module Sai
  class Model
    module Core
      autoload :Comparison,    'sai/model/core/comparison'
      autoload :Configuration, 'sai/model/core/configuration'
      autoload :Conversion,    'sai/model/core/conversion'
      autoload :Introspection, 'sai/model/core/introspection'
      autoload :Opacity,       'sai/model/core/opacity'
    end

    autoload :CMYK,  'sai/model/cmyk'
    autoload :HSB,   'sai/model/hsv'
    autoload :HSL,   'sai/model/hsl'
    autoload :HSV,   'sai/model/hsv'
    autoload :Lab,   'sai/model/lab'
    autoload :LCH,   'sai/model/lch'
    autoload :LMS,   'sai/model/lms'
    autoload :Luv,   'sai/model/luv'
    autoload :Oklab, 'sai/model/oklab'
    autoload :Oklch, 'sai/model/oklch'
    autoload :RGB,   'sai/model/rgb'
    autoload :XYZ,   'sai/model/xyz'

    include Channel::Management
    include Core::Comparison
    include Core::Configuration
    include Core::Conversion
    include Core::Introspection
    include Core::Opacity

    def initialize(*channels, **options)
      initialize_opacity(**options)
      initialize_channels(*channels, **options)
      initialize_configuration(**options)
    end
  end
end
