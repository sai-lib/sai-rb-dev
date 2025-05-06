# frozen_string_literal: true

module Sai
  module Space
    module Encoded
      class RGB
        module Derivative
          class << self
            private

            def included(base)
              super

              base.extend  ClassMethods
              base.include InstanceMethods

              base.instance_eval do
                with_native(illuminant: native_rgb_space.native_context.illuminant)

                attribute :rgb_space, Class, default: -> { self.class.native_rgb_space }, required: true

                validates :rgb_space, 'must be a subclass of Sai::Space::Encoded::RGB' do
                  rgb_space < RGB
                end
              end
            end

            module ClassMethods
              def native_rgb_space
                concurrent_instance_variable_fetch(:@native_rgb_space, Sai.config.default_rgb_space)
              end

              private

              def with_native(**options)
                rgb_space = options.fetch(:rgb_space, Sai.config.default_rgb_space)
                unless rgb_space < RGB
                  raise TypeError, '`:rgb_space` is invalid. Expected a subclass of `Sai::Space::Encoded::RGB`, ' \
                                   "got: #{rgb_space.inspect}"
                end
                mutex.synchronize { @native_rgb_space = rgb_space }

                super
              end
            end

            module InstanceMethods
              def to_xyz(...)
                to_rgb(...).to_xyz(...)
              end

              private

              def convert_to_encoded(space, **options, &)
                rgb_space = options.fetch(:rgb_space, self.rgb_space)
                if space == rgb_space
                  convert_to(space, rgb_space:, map_to_gamut: true, **options, &)
                else
                  to_rgb(rgb_space:, **options).public_send(:"to_#{space.identifier}", **options)
                end
              end

              def convert_to_rgb(**options, &)
                rgb_space = options.fetch(:rgb_space, Sai.config.default_rgb_space)
                rgb = convert_to(rgb_space, map_to_gamut: true, **options, &)
                rgb_space == self.rgb_space ? rgb : rgb.to_rgb(rgb_space: space)
              end

              def convert_to_self(**options)
                rgb_space = options.fetch(:rgb_space, self.rgb_space)
                return super if rgb_space == self.rgb_space

                coerce(to_rgb(rgb_space:, map_to_gamut: true, **options))
              end

              def identity_attributes
                [*super, rgb_space].freeze
              end
            end
          end
        end
      end
    end
  end
end
