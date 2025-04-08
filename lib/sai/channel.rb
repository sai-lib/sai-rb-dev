# frozen_string_literal: true

module Sai
  class Channel
    autoload :Bipolar,         'sai/channel/bipolar'
    autoload :Boundary,        'sai/channel/boundary'
    autoload :Circular,        'sai/channel/circular'
    autoload :Linear,          'sai/channel/linear'
    autoload :Management,      'sai/channel/management'
    autoload :MethodGenerator, 'sai/channel/method_generator'
    autoload :Set,             'sai/channel/set'
    autoload :Value,           'sai/channel/value'

    Display = Struct.new(:format, :precision, keyword_init: true)

    attr_reader :boundary
    attr_reader :differential_step
    attr_reader :display
    attr_reader :name
    attr_reader :symbol

    def initialize(**options)
      %i[name symbol].each do |key|
        raise ArgumentError, "missing keyword: `:#{key}`" unless options.key?(key)
      end

      @differential_step = options.fetch(:differential_step, 1.0)
      @name = options.fetch(:name).to_sym
      @required = !options.fetch(:optional, false)
      @symbol = options.fetch(:symbol).to_sym

      @boundary = Boundary.new(options.fetch(:bounds, nil))

      precision = options.fetch(:display_precision, 0)
      @display = Display.new(
        format: options.fetch(:display_format, "%.#{precision}f"),
        precision:,
      )

      freeze
    end

    def contract(value, scalar)
      raise NotImplementedError, "`#{self.class}` does not implement `#contract`"
    end

    def decrement(value, amount)
      raise NotImplementedError, "`#{self.class}` does not implement `#decrement`"
    end

    def denormalize(value)
      raise NotImplementedError, "`#{self.class}` does not implement `#denormalize`"
    end

    def exponentiate(value, exponent)
      raise NotImplementedError, "`#{self.class}` does not implement `#exponentiate`"
    end

    def increment(value, amount)
      raise NotImplementedError, "`#{self.class}` does not implement `#increment`"
    end

    def normalize(value)
      raise NotImplementedError, "`#{self.class}` does not implement `#normalize`"
    end

    def required?
      @required
    end

    def scale(value, scalar)
      raise NotImplementedError, "`#{self.class}` does not implement `#scale`"
    end
  end
end
