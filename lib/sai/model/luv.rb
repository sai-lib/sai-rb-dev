# frozen_string_literal: true

module Sai
  class Model
    class Luv < Model
      channel :lightness, :l, :percentage, display_precision: 2, differential_step: 0.2
      channel :u, :u, :bipolar, display_precision: 2, differential_step: 0.2
      channel :v, :v, :bipolar, display_precision: 2, differential_step: 0.2
    end
  end
end
