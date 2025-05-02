# frozen_string_literal: true

module Sai
  module Model
    autoload :CMY,        'sai/model/cmy'
    autoload :CMYK,       'sai/model/cmyk'
    autoload :Component,  'sai/model/component'
    autoload :Definition, 'sai/model/definition'
    autoload :HSL,        'sai/model/hsl'
    autoload :HSV,        'sai/model/hsv'
    autoload :LAB,        'sai/model/lab'
    autoload :LCH,        'sai/model/lch'
    autoload :LMS,        'sai/model/lms'
    autoload :LUV,        'sai/model/luv'
    autoload :RGB,        'sai/model/rgb'
    autoload :UV,         'sai/model/uv'
    autoload :XY,         'sai/model/xy'
    autoload :XYZ,        'sai/model/xyz'

    class << self
      def implemented_by?(object)
        object.class.respond_to?(:components) && object.class.components.is_a?(Component::Definition::Set)
      end
      alias === implemented_by?
    end
  end
end
