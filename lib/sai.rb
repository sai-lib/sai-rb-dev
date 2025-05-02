# frozen_string_literal: true

module Sai
  EMPTY_ARRAY = [].freeze
  private_constant :EMPTY_ARRAY

  EMPTY_HASH = {}.freeze
  private_constant :EMPTY_HASH

  autoload :Core, 'sai/core'

  autoload :Error,         'sai/errors/error'
  autoload :IdentityError, 'sai/errors/identity_error'
end
