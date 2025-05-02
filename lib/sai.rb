# frozen_string_literal: true

module Sai
  EMPTY_ARRAY = [].freeze
  private_constant :EMPTY_ARRAY

  EMPTY_HASH = {}.freeze
  private_constant :EMPTY_HASH

  autoload :Core, 'sai/core'

  autoload :ConfigurationError, 'sai/errors/configuration_error'
  autoload :Error,              'sai/errors/error'
  autoload :IdentityError,      'sai/errors/identity_error'

  extend Core::Concurrency

  class << self
    def config
      concurrent_instance_variable_fetch(:@config, Core::Configuration.new)
    end

    def configure(&block)
      block&.arity&.zero? ? config.instance_exec(&block) : (yield(config) if block)
    end
  end
end
