# frozen_string_literal: true

module Sai
  module Space
    module Physiological
      class Base < Space::Base
        abstract_space

        class << self
          def native_context
            nil
          end
        end

        def source_white
          local_context&.white_point || Spectral::Tristimulus.new(1, 1, 1)
        end
      end
    end
  end
end
