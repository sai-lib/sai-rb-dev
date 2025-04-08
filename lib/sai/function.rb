# frozen_string_literal: true

module Sai
  module Function
    def cmyk(*channels, **options)
      Model::CMYK.new(*channels, **options)
    end

    def hsl(*channels, **options)
      Model::HSL.new(*channels, **options)
    end

    def hsv(*channels, **options)
      Model::HSV.new(*channels, **options)
    end
    alias hsb hsv

    def lab(*channels, **options)
      Model::Lab.new(*channels, **options)
    end

    def lch(*channels, **options)
      Model::LCH.new(*channels, **options)
    end

    def lms(*channels, **options)
      Model::LMS.new(*channels, **options)
    end

    def luv(*channels, **options)
      Model::Luv.new(*channels, **options)
    end

    def oklab(*channels, **options)
      Model::Oklab.new(*channels, **options)
    end

    def oklch(*channels, **options)
      Model::Oklch.new(*channels, **options)
    end

    def rgb(*channels, **options)
      Model::RGB.new(*channels, **options)
    end

    def xyz(*channels, **options)
      Model::XYZ.new(*channels, **options)
    end
  end
end
