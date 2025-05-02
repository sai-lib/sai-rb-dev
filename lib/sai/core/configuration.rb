# frozen_string_literal: true

module Sai
  module Core
    class Configuration
      include Concurrency

      class << self
        def defaults
          concurrent_instance_variable_fetch(:@defaults, EMPTY_HASH)
        end

        private

        def default(name, default_value = nil, &block)
          key = name.to_sym
          new_defaults = defaults.merge(key => { value: default_value || block }.freeze).freeze

          mutex.synchronize do
            define_method(:"default_#{key}") do
              ivar_value = instance_variable_get(:"@default_#{key}")
              return ivar_value unless ivar_value.is_a?(Proc)

              resolved_value = instance_exec(&ivar_value)
              mutex.synchronize { instance_variable_set(:"@default_#{key}", resolved_value) }
            end

            define_method(:"set_default_#{key}") do |value|
              validator, message = self.class.defaults[key][:validator]
              raise ConfigurationError, "#{key} #{message}" if validator && !instance_exec(value, &validator)

              mutex.synchronize { instance_variable_set(:"@default_#{key}", value) }
            end

            @defaults = new_defaults
          end
        end

        def validates(name, message, &block)
          new_defaults = defaults.dup
          new_defaults[name.to_sym] = new_defaults[name.to_sym].merge(validator: [block, message]).freeze
          mutex.synchronize { @defaults = new_defaults.freeze }
        end
      end

      default(:cache_store) { Cache::LRUStore }

      default(:cache_options, { max_size: 2_048_000 })

      default(:chromatic_adaptation_transform) { ChromaticAdaptationTransform::BRADFORD }
      alias default_cat default_chromatic_adaptation_transform
      alias set_default_cat set_default_chromatic_adaptation_transform

      default(:cone_transform) { ChromaticAdaptationTransform::HUNT_POINTER_ESTEVEZ }

      default(:correlated_color_temperature_formula) { Formula::CorrelatedColorTemperature::Ohno }
      alias default_cct_formula default_correlated_color_temperature_formula
      alias set_default_cct_formula set_default_correlated_color_temperature_formula

      default(:observer) { Observer::CIE_1931 }

      validates :cache_store, 'must be a `Sai::Core::Cache::Store`' do |store|
        store < Cache::Store
      end

      validates :cache_options, 'must be a `Hash[Symbol, Object]`' do |options|
        options.is_a?(Hash) && options.keys.all?(Symbol)
      end

      validates :chromatic_adaptation_transform, 'must be a `Sai::ChromaticAdaptationTransform`' do |cat|
        cat.is_a?(ChromaticAdaptationTransform)
      end

      validates :cone_transform, 'must be a `Sai::ChromaticAdaptationTransform`' do |cat|
        cat.is_a?(ChromaticAdaptationTransform)
      end

      validates :correlated_color_temperature_formula,
                'must be a `Sai::Formula::CorrelatedColorTemperature`' do |formula|
        formula.is_a?(Formula::CorrelatedColorTemperature)
      end

      validates :observer, 'must be a `Sai::Observer`' do |observer|
        observer.is_a?(Observer)
      end

      def initialize
        self.class.defaults.each_pair do |attribute, config|
          instance_variable_set(:"@default_#{attribute}", config[:value])
        end
      end

      def disable_caching
        set_default_cache_store(Cache::NullStore)
        set_default_cache_options({})

        Sai.send(:mutex).synchronize { Sai.instance_variable_set(:@cache, nil) }
      end

      def enable_caching(store: Cache::LRUStore, **options)
        set_default_cache_store(store)
        set_default_cache_options(options)

        Sai.send(:mutex).synchronize { Sai.instance_variable_set(:@cache, nil) }
      end
    end
  end
end
