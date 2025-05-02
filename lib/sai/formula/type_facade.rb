# frozen_string_literal: true

module Sai
  module Formula
    module TypeFacade
      def ===(other)
        other.is_a?(self)
      end

      def is_a?(mod)
        mod.name.start_with?(Sai::Formula.name) && name.start_with?(mod.name)
      end
    end
    private_constant :TypeFacade
  end
end
