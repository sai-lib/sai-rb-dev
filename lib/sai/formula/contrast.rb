# frozen_string_literal: true

module Sai
  module Formula
    module Contrast
      autoload :APCA,      'sai/formula/contrast/apca'
      autoload :CIELab,    'sai/formula/contrast/cielab'
      autoload :MBS,       'sai/formula/contrast/mbs'
      autoload :Michelson, 'sai/formula/contrast/michelson'
      autoload :RMS,       'sai/formula/contrast/rms'
      autoload :SAPC,      'sai/formula/contrast/sapc'
      autoload :WCAG,      'sai/formula/contrast/wcag'
      autoload :Weber,     'sai/formula/contrast/weber'

      extend TypeFacade
    end
  end
end
