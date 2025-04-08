# frozen_string_literal: true

module Sai
  module Enum
    module ColorModel
      extend Enum

      value(:cmyk) { Model::CMYK }

      value(:hsl) { Model::HSL }

      value(:hsv) { Model::HSV }
      alias_value :hsb, :hsv

      value(:lab) { Model::Lab }

      value(:lch) { Model::LCH }

      value(:lms) { Model::LMS }

      value(:luv) { Model::Luv }

      value(:oklab) { Model::Oklab }

      value(:oklch) { Model::Oklch }

      value(:rgb) { Model::RGB }

      value(:xyz) { Model::XYZ }
    end
  end
end
