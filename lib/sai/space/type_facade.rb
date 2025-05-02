# frozen_string_literal: true

module Sai
  module Space
    module TypeFacade
      def ===(other)
        other.is_a?(self) || super
      end
    end
    private_constant :TypeFacade
  end
end
