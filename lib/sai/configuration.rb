# frozen_string_literal: true

module Sai
  class Configuration
    attr_reader :default_cache_store

    class << self
      def defaults
        @defaults ||= EMPTY_HASH
      end

      private

      def default(name, value, *valid_types)
        thread_lock.synchronize do
          attr_reader :"default_#{name}"

          @defaults = defaults.merge(name.to_sym => value).freeze

          define_method(:"set_default_#{name}") do |object|
            unless valid_types.any? { |type| type.is_a?(Proc) ? type.call(object) : object.is_a?(type) }
              raise TypeError, "`#{name}` is invalid. Expected `#{valid_types.join(' | ')}`, got #{object.inspect}"
            end

            instance_variable_set(:"@default_#{name}", object)
          end
        end
      end

      def thread_lock
        @thread_lock ||= Mutex.new
      end
    end

    default :cache_size, 2_048_000, Integer

    default :chromatic_adaptation_transform, Sai::Enum::ChromaticAdaptationTransform::BRADFORD,
            Sai::ChromaticAdaptationTransform, Sai::Enum::ChromaticAdaptationTransform
    alias default_cat default_chromatic_adaptation_transform
    alias set_default_cat set_default_chromatic_adaptation_transform

    default :color_space, Sai::Enum::ColorSpace::SRGB, Sai::Space, Sai::Enum::ColorSpace

    default :cone_fundamentals_transform, Sai::Enum::ChromaticAdaptationTransform::HUNT_POINTER_ESTEVEZ,
            Sai::ChromaticAdaptationTransform, Sai::Enum::ChromaticAdaptationTransform

    default :correlated_color_temperature_formula, Sai::Enum::Formula::CorrelatedColorTemperature::OHNO,
            ->(f) { f.name.start_with?(Sai::Formula::CorrelatedColorTemperature.name) },
            Sai::Enum::Formula::CorrelatedColorTemperature
    alias default_cct_formula default_correlated_color_temperature_formula
    alias set_default_cct_formula set_default_correlated_color_temperature_formula

    default :illuminant, Sai::Enum::Illuminant::D65, Sai::Illuminant, Sai::Enum::Illuminant

    default :observer, Sai::Enum::Observer::CIE1931, Sai::Observer, Sai::Enum::Observer

    def initialize
      self.class.defaults.each_pair { |attribute, value| instance_variable_set(:"@default_#{attribute}", value) }
      @default_cache_store ||= Sai::Enum::CacheStore::MEMORY
    end

    def disable_caching
      @default_cache_store = Sai::Enum::CacheStore::Null

      Sai.instance_variable_set(:@cache, Sai::Cache::NullStore.new)
    end

    def enable_caching(store: default_cache_store, size: default_cache_size)
      @default_cache_size = size
      @default_cache_store = store
      Sai.instance_variable_set(:@cache, store.new(max_size: size))
    end
  end
end
