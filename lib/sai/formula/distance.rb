# frozen_string_literal: true

module Sai
  module Formula
    module Distance
      autoload :Application, 'sai/formula/distance/application'
      autoload :CIE76,       'sai/formula/distance/cie76'
      autoload :CIE94,       'sai/formula/distance/cie94'
      autoload :CIECMC,      'sai/formula/distance/ciecmc'
      autoload :CIEDE2000,   'sai/formula/distance/ciede2000'
      autoload :DeltaE,      'sai/formula/distance/delta_e'
      autoload :Euclidean,   'sai/formula/distance/euclidean'
      autoload :Manhattan,   'sai/formula/distance/manhattan'

      extend TypeFacade
    end
  end
end
