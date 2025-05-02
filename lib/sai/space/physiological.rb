# frozen_string_literal: true

module Sai
  module Space
    module Physiological
      autoload :Base, 'sai/space/physiological/base'
      autoload :LMS,  'sai/space/physiological/lms'
      autoload :XYZ,  'sai/space/physiological/xyz'

      extend TypeFacade
    end
  end
end
