# frozen_string_literal: true

module Sai
  class Model
    class CMYK < Model
      channel :cyan, :c, :percentage, differential_step: 0.5
      channel :magenta, :m, :percentage, differential_step: 0.5
      channel :yellow, :y, :percentage, differential_step: 0.5
      channel :key, :k, :percentage, differential_step: 0.5
    end
  end
end
