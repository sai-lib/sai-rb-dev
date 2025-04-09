# frozen_string_literal: true

module Sai
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

    Attribute = Struct.new(:aliases, :coercer, :default, :name, :types, :validations, keyword_init: true) do
      def initialize(name:, aliases: EMPTY_ARRAY, coercer: nil, computed: false, default: Undefined,
                     depends_on: EMPTY_ARRAY, required: false, types: EMPTY_ARRAY, validations: EMPTY_ARRAY)
        super(aliases:, coercer:, default:, name:, types:, validations:)
        @computed = computed
        @name = name.to_sym
        @dependencies = depends_on
        @required = required
      end

      def computed?
        @computed
      end

      def dependencies
        @dependencies
      end

      def required?
        @required
      end
    end

    class << self
      private

      def included(base)
        super

        base.extend ClassMethods
      end
    end

    module ClassMethods
      def attribute_names
        @attributes.keys.sort
      end

      def attributes
        @attributes ||= EMPTY_HASH
      end

      private

      def alias_attribute(new_name, old_name)
        thread_lock.synchronize do
          alias_name = new_name.to_sym
          attribute = attributes[old_name.to_sym].dup
          attribute.aliases = attribute.aliases.dup.push(alias_name).compact.uniq.sort.freeze
          @attributes = attributes.merge(attribute.name => attribute.freeze).freeze

          alias_method(alias_name, attribute.name) unless method_defined?(alias_name)
        end
      end

      def attribute(name, *types, coerce: nil, default: Undefined, depends_on: EMPTY_ARRAY, required: false)
        thread_lock.synchronize do
          attribute = Attribute.new(name:, types:, coercer: coerce, default:, depends_on:, required:)
          @attributes = attributes.merge(attribute.name => attribute.freeze).freeze
          attr_reader attribute.name
        end
      end

      def computed_attribute(name, value = nil, depends_on: EMPTY_ARRAY, &value_block)
        thread_lock.synchronize do
          attribute = Attribute.new(name:, computed: true, default: value || value_block, depends_on:)
          @attributes = attributes.merge(attribute.name => attribute.freeze).freeze
          attr_reader attribute.name
        end
      end

      def thread_lock
        @thread_lock ||= Mutex.new
      end

      def validates(*attribute_names, message, &validation)
        thread_lock.synchronize do
          attribute_names.each do |attribute_name|
            attribute = attributes[attribute_name.to_sym].dup
            attribute.validations = attribute.validations.dup.push([message, validation].freeze).freeze
            @attributes = attributes.merge(attribute.name => attribute.freeze).freeze
          end
        end
      end
    end

    def initialize(**attributes)
      self.class.attribute_names.each { |name| initialize_attribute!(attributes, name) }
    end

    def ==(other)
      other.is_a?(self.class) && self.class.attribute_names.all? do |name|
        instance_variable_get(:"@#{name}") == other.instance_variable_get(:"@#{name}")
      end
    end

    def hash
      to_hash.hash
    end

    def to_hash
      self.class.attribute_names.each_with_object({}) do |name, result|
        result[name] = serialize_value(instance_variable_get(:"@#{name}"))
      end
    end
    alias to_h to_hash

    private

    def initialize_attribute!(attributes, name)
      return if instance_variable_defined?(:"@#{name}")

      config = self.class.attributes[name]
      config.dependencies.each { |dependency| initialize_attribute!(attributes, dependency) }

      value = if config.computed?
                config.default.is_a?(Proc) ? instance_exec(&config.default) : config.default
              else
                key = attributes.key?(name) ? name : config.aliases.find { |alias_name| attributes.key?(alias_name) }
                process_attribute!(name, key ? attributes[key] : nil)
              end

      instance_variable_set(:"@#{name}", value)
    end

    def process_attribute!(name, value)
      config = self.class.attributes[name]
      original_value = value.dup
      default_or_value = if original_value.nil? && config.default != Undefined
                           config.default.is_a?(Proc) ? instance_exec(&config.default) : config.default
                         else
                           original_value
                         end

      raise ArgumentError, "missing keyword: `:#{name}`" if default_or_value.nil? && config.required?
      return if default_or_value.nil? && !config.required?

      resolved_value = Enum.resolve(default_or_value)
      coerced_value = case config.coercer
                      when Proc then instance_exec(resolved_value, &config.coercer)
                      when Symbol then send(config.coercer, resolved_value)
                      else resolved_value
                      end

      types = config.types
      unless types.empty? || types.any? { |type| type === coerced_value || coerced_value.is_a?(type) }
        type_msg = types.size == 1 ? "Expected `#{types.first}`" : "Expected `#{types.join(' | ')}`"
        raise TypeError, "`#{name}` is invalid. #{type_msg}, got: #{coerced_value.inspect}"
      end

      validations = config.validations
      unless validations.empty?
        validations.each do |message, validation|
          next if validation.call(coerced_value)

          raise ArgumentError, "`#{name}` #{message}"
        end
      end

      coerced_value
    rescue StandardError => e
      raise e if e.is_a?(Sai::Error)

      coerced_value || resolved_value || default_or_value || original_value
    end

    def recompute_computed_attributes!
      self.class.attributes.select { |_, v| v.computed? }.each do |name, attribute|
        value = attribute.default.is_a?(Proc) ? instance_exec(&attribute.default) : attribute.default
        instance_variable_set(:"@#{name}", value)
      end
    end

    def serialize_value(value)
      if value.is_a?(Array)
        value.map { |v| serialize_value(v) }
      elsif value.is_a?(Hash)
        value.transform_values { |v| serialize_value(v) }
      elsif value.respond_to?(:to_h)
        serialize_value(value.to_h)
      elsif value.respond_to?(:to_a)
        serialize_value(value.to_a)
      elsif value.respond_to?(:normalized)
        value.normalized
      else
        value
      end
    end
  end
end
