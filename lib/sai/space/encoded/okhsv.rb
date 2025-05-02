# frozen_string_literal: true

module Sai
  module Space
    module Encoded
      class Okhsv < Base
        implements Model::HSV
        with_native illuminant: Illuminant::D65

        def to_okhsv(...)
          convert_to_self(...)
        end
      end
    end
  end
end
