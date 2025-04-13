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

      module BT709
        RED_COEFFICIENT = 0.2126
        GREEN_COEFFICIENT = 0.7152
        BLUE_COEFFICIENT = 0.0722
      end
    end
  end
end
