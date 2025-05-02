# frozen_string_literal: true

module Sai
  module Core
    module ManagedAttributes
      Undefined = Object.new.tap do |object|
        def object.copy(...)
          self
        end

        def object.dup(...)
          self
        end
      end.freeze
      private_constant :Undefined

      Attribute = Struct.new(:aliases, :coercer, :default, :dependencies, :name, :types, :validations,
                             keyword_init: true) do
        def initialize(name:, aliases: EMPTY_ARRAY, coercer: nil, default: Undefined, dependencies: EMPTY_ARRAY,
                       required: false, types: EMPTY_ARRAY, validations: EMPTY_ARRAY)
          super(
            aliases:,
            coercer:,
            default:,
            dependencies:,
            name: name.to_sym,
            types:,
            validations:
          )

          @required = required
        end

        def required?
          @required
        end
      end

      class << self
        private

        def included(base)
          super

          base.extend  ClassMethods
          base.include Concurrency
          base.include InstanceMethods
        end
      end

      module ClassMethods
        def attribute_names
          (@attributes.keys + @attributes.values.flat_map(&:aliases)).compact.uniq.sort
        end

        def attributes
          concurrent_instance_variable_fetch(:@attributes, EMPTY_HASH)
        end

        private

        def alias_attribute(new_name, old_name)
          mutex.synchronize do
            alias_name        = new_name.to_sym
            attribute         = attributes[old_name.to_sym].dup
            attribute.aliases = attribute.aliases.dup.push(alias_name).compact.uniq.sort.freeze
            @attributes       = attributes.merge(attribute.name => attribute.freeze).freeze

            alias_method(alias_name, attribute.name) unless method_defined?(alias_name)
          end
        end

        def attribute(name, *types, coerce: nil, default: Undefined, depends_on: EMPTY_ARRAY, required: false)
          attribute = create_or_update_attribute(
            name, types:, coercer: coerce, default:, dependencies: depends_on, required:
          )

          mutex.synchronize do
            @attributes = attributes.merge(attribute.name => attribute.freeze).freeze
            attr_reader attribute.name
          end
        end

        def create_or_update_attribute(name, **options)
          attribute_props = attributes[name.to_sym]&.to_h || { name: name.to_sym }
          attribute_props = attribute_props.merge(
            options.compact.reject { |k, v| k != :default && v.respond_to?(:empty?) && v.empty? },
          )
          Attribute.new(**attribute_props)
        end

        def inherited(subclass)
          super

          subclass.send(:mutex).synchronize do
            subclass.instance_variable_set(:@attributes, attributes.transform_values { |v| v.dup.freeze }.freeze)
          end
        end

        def validates(*attribute_names, message, &validation)
          mutex.synchronize do
            attribute_names.each do |attribute_name|
              attribute             = attributes[attribute_name.to_sym].dup
              attribute.validations = attribute.validations.dup.push([message, validation].freeze).freeze
              @attributes           = attributes.merge(attribute.name => attribute.freeze).freeze
            end
          end
        end
      end

      module InstanceMethods
        def attributes
          self.class.attribute_names.each_with_object({}) do |name, result|
            result[name] = serialize_value(instance_variable_get(:"@#{name}"))
          end
        end

        private

        def initialize_attribute!(attributes, name)
          config = self.class.attributes[name]
          config ||= self.class.attributes.values.find { |attribute| attribute.aliases.include?(name) }

          return if instance_variable_defined?(:"@#{config.name}")

          config.dependencies.each { |dependency| initialize_attribute!(attributes, dependency) }

          key = attributes.key?(config.name) ? config.name : config.aliases.find { |k| attributes.key?(k) }
          value = process_attribute!(config.name, key ? attributes[key] : nil)

          instance_variable_set(:"@#{config.name}", value)
        end

        def initialize_attributes!(**attributes)
          return if self.class.attributes.empty?

          self.class.attribute_names.each { |name| initialize_attribute!(attributes, name) }
        end

        def process_attribute!(name, value)
          config           = self.class.attributes[name]
          original_value   = value.is_a?(Class) || value.is_a?(Module) ? value : value.dup
          default_or_value = if original_value.nil? && config.default != Undefined
                               config.default.is_a?(Proc) ? instance_exec(&config.default) : config.default
                             else
                               original_value
                             end

          raise ArgumentError, "missing keyword: `:#{name}`" if default_or_value.nil? && config.required?
          return if default_or_value.nil? && !config.required?

          coerced_value = case config.coercer
                          when Proc then instance_exec(default_or_value, &config.coercer)
                          when Symbol then send(config.coercer, default_or_value)
                          else default_or_value
                          end

          types = config.types
          unless types.empty? || types.any? { |type| type === coerced_value || coerced_value.is_a?(type) }
            type_msg = types.size == 1 ? "Expected `#{types.first}`" : "Expected `#{types.join(' | ')}`"
            raise TypeError, "`#{name}` is invalid. #{type_msg}, got: #{coerced_value.inspect}"
          end

          validations = config.validations
          unless validations.empty?
            validations.each do |message, validation|
              next if instance_exec(coerced_value, &validation)

              raise ArgumentError, "`#{name}` #{message}"
            end
          end

          coerced_value
        rescue StandardError => e
          raise e if e.is_a?(Sai::Error)

          coerced_value || default_or_value || original_value
        end

        def serialize_value(value)
          if value.respond_to?(:serialize)
            serialize_value(value.serialize)
          elsif value.is_a?(Array)
            value.map { |v| serialize_value(v) }
          elsif value.is_a?(Hash)
            value.transform_values { |v| serialize_value(v) }
          elsif value.respond_to?(:to_h)
            begin
              serialize_value(value.to_h)
            rescue StandardError => e
              raise e unless value.respond_to?(:to_a)

              serialize_value(value.to_a)
            end
          elsif value.respond_to?(:to_a)
            begin
              serialize_value(value.to_a)
            rescue StandardError => e
              raise e unless value.respond_to?(:to_h)

              serialize_value(value.to_h)
            end
          else
            value
          end
        end
      end
    end
  end
end
