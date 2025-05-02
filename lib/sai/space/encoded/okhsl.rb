# frozen_string_literal: true

module Sai
  module Space
    module Encoded
      class Okhsl < Base
        implements Model::HSL
        with_native illuminant: Illuminant::D65

        def to_okhsl(...)
          convert_to_self(...)
        end
      end
    end
  end
end
