# frozen_string_literal: true

module Sai
  EMPTY_ARRAY = [].freeze
  private_constant :EMPTY_ARRAY

  EMPTY_HASH = {}.freeze
  private_constant :EMPTY_HASH

  autoload :Error, 'sai/errors/error'
end
