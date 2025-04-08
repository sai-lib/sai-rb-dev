# frozen_string_literal: true

module Sai
  class Model
    module Core
      module Comparison
        def ==(other)
          (other.is_a?(self.class) && other.to_array == to_array) ||
            (other.is_a?(Array) && other == to_n_a)
        end
      end
    end
  end
end
