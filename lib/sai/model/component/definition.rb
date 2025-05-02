# frozen_string_literal: true

module Sai
  module Model
    module Component
      module Definition
        autoload :Base,     'sai/model/component/definition/base'
        autoload :Boundary, 'sai/model/component/definition/boundary'
        autoload :Circular, 'sai/model/component/definition/circular'
        autoload :Linear,   'sai/model/component/definition/linear'
        autoload :Opponent, 'sai/model/component/definition/opponent'
        autoload :Set,      'sai/model/component/definition/set'
      end
    end
  end
end
