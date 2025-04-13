# frozen_string_literal: true

module Sai
  module Enum
    module Gamut
      module MappingStrategy
        extend Enum

        value(:clip) { :clip }
        value(:compress) { :compress }
        value(:scale) { :scale }
      end
    end
  end
end
