# frozen_string_literal: true

module Sai
  module Model
    LMS = Definition.new(:LMS) do
      component :long,   :l, :linear, display_precision: 6, differential_step: 0.0005
      component :medium, :m, :linear, display_precision: 6, differential_step: 0.0005
      component :short,  :s, :linear, display_precision: 6, differential_step: 0.0005
    end
  end
end
