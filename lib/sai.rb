# frozen_string_literal: true

# A powerful color science toolkit for seamless cross-space manipulation.
#
# Sai is a sophisticated color management system built on precise color science principles. It provides a unified
# interface across multiple color spaces (RGB, HSL, CMYK, CIE Lab, Oklab, and more), allowing operations in any space to
# intelligently propagate throughout the entire color ecosystem.
#
# Key features include cross-space operations, perceptually accurate color comparisons using multiple Delta-E
# algorithms, accessibility tools for contrast evaluation, sophisticated color matching, and scientific color analysis
# with CIE standards support.
#
# Sai empowers developers to work with colors consistently across different environments and applications. Whether
# developing design tools, data visualizations, or accessibility-focused applications, Sai provides both mathematical
# precision and an intuitive API for sophisticated color manipulation.
#
# @since 0.1.0
module Sai
  autoload :ArgumentError,                'sai/errors/argument_error'
  autoload :Cache,                        'sai/cache'
  autoload :Channel,                      'sai/channel'
  autoload :ChromaticAdaptationTransform, 'sai/chromatic_adaptation_transform'
  autoload :Chromaticity,                 'sai/chromaticity'
  autoload :Configuration,                'sai/configuration'
  autoload :DataStore,                    'sai/data_store'
  autoload :DimensionMismatchError,       'sai/errors/dimension_mismatch_error'
  autoload :Enum,                         'sai/enum'
  autoload :Error,                        'sai/errors/error'
  autoload :Formula,                      'sai/formula'
  autoload :Function,                     'sai/function'
  autoload :Illuminant,                   'sai/illuminant'
  autoload :Inflection,                   'sai/inflection'
  autoload :InvalidColorValueError,       'sai/errors/invalid_color_value_error'
  autoload :InvalidDataFileError,         'sai/errors/invalid_data_file_error'
  autoload :ManagedAttributes,            'sai/managed_attributes'
  autoload :Matrix,                       'sai/matrix'
  autoload :MatrixError,                  'sai/errors/matrix_error'
  autoload :Model,                        'sai/model'
  autoload :Observer,                     'sai/observer'
  autoload :TypeError,                    'sai/errors/type_error'
  autoload :UnevenWavelengthError,        'sai/errors/uneven_wavelength_error'
  autoload :WavelengthRange,              'sai/wavelength_range'
  autoload :ZeroDeterminantError,         'sai/errors/zero_determinant_error'

  EMPTY_ARRAY = [].freeze
  private_constant :EMPTY_ARRAY

  EMPTY_HASH = {}.freeze
  private_constant :EMPTY_HASH

  EMPTY_STRING = ''
  private_constant :EMPTY_STRING

  FRACTION_RANGE = 0.0..1.0
  private_constant :FRACTION_RANGE

  PERCENTAGE_RANGE = 0.0..100.0
  private_constant :PERCENTAGE_RANGE

  class << self
    include Function

    def cache
      @cache ||= Sai.config.default_cache_store.new(max_size: Sai.config.default_cache_size)
    end

    def config
      @config ||= Configuration.new
    end

    def configure(&block)
      block && block.arity == 1 ? yield(config) : config.instance_exec(&block)
    end

    def data_store
      @data_store ||= DataStore.new
    end

    def enum
      Enum
    end
  end
end
