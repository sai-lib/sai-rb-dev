# frozen_string_literal: true

module Sai
  EMPTY_ARRAY = [].freeze
  private_constant :EMPTY_ARRAY

  EMPTY_HASH = {}.freeze
  private_constant :EMPTY_HASH

  FRACTION_RANGE = 0.0..1.0
  private_constant :FRACTION_RANGE

  PERCENTAGE_RANGE = 0.0..100.0
  private_constant :PERCENTAGE_RANGE

  autoload :CAT,                          'sai/chromatic_adaptation_transform'
  autoload :ChromaticAdaptationTransform, 'sai/chromatic_adaptation_transform'
  autoload :Chromaticity,                 'sai/chromaticity'
  autoload :Core,                         'sai/core'
  autoload :Formula,                      'sai/formula'
  autoload :Model,                        'sai/model'
  autoload :Illuminant,                   'sai/illuminant'
  autoload :Observer,                     'sai/observer'
  autoload :Space,                        'sai/space'
  autoload :Spectral,                     'sai/spectral'
  autoload :Standard,                     'sai/standard'

  autoload :ConfigurationError,     'sai/errors/configuration_error'
  autoload :DimensionMismatchError, 'sai/errors/dimension_mismatch_error'
  autoload :Error,                  'sai/errors/error'
  autoload :IdentityError,          'sai/errors/identity_error'
  autoload :InstantiationError,     'sai/errors/instantiation_error'
  autoload :InvalidColorValueError, 'sai/errors/invalid_color_value_error'
  autoload :InvalidDataFileError,   'sai/errors/invalid_data_file_error'
  autoload :MatrixError,            'sai/errors/matrix_error'
  autoload :UnevenWavelengthError,  'sai/errors/uneven_wavelength_error'
  autoload :ZeroDeterminantError,   'sai/errors/zero_determinant_error'

  extend Core::Concurrency

  class << self
    def cache
      concurrent_instance_variable_fetch(
        :@cache,
        config.default_cache_store.new(**config.default_cache_options),
      )
    end

    def config
      concurrent_instance_variable_fetch(:@config, Core::Configuration.new)
    end

    def configure(&block)
      block&.arity&.zero? ? config.instance_exec(&block) : (yield(config) if block)
    end

    def data_store
      concurrent_instance_variable_fetch(:@data_store, Core::DataStore.new)
    end
  end
end
