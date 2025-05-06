# frozen_string_literal: true

module Sai
  module Space
    module Encoded
      class Okhsv < Base
        include RGB::Derivative

        implements Model::HSV
        with_native illuminant: Illuminant::D65, rgb_space: RGB::Standard

        def to_okhsv(...)
          convert_to_self(...)
        end
      end
    end
  end
end
