# frozen_string_literal: true

module Sai
  module Space
    module Core
      module Context
        class << self
          private

          def included(base)
            super

            base.extend  ClassMethods
            base.include Sai::Core::Concurrency
            base.include InstanceMethods
          end
        end

        module ClassMethods
          def native_context
            concurrent_instance_variable_fetch(:@native_context, Space::Context.new)
          end

          def with_native(**options)
            chromatic_adaptation_transform = options.fetch(
              :chromatic_adaptation_transform,
              options.fetch(:cat, native_context&.chromatic_adaptation_transform),
            )
            cone_transform = options.fetch(:cone_transform, native_context&.cone_transform)
            illuminant     = options.fetch(:illuminant, native_context&.illuminant)
            observer       = options.fetch(:observer, native_context&.observer)

            context = native_context.with(
              chromatic_adaptation_transform:,
              cone_transform:,
              illuminant:,
              observer:,
            )

            mutex.synchronize { @native_context = context }
          end
        end

        module InstanceMethods
          attr_reader :local_context

          def with_context(**options)
            context = local_context&.with(**options) || Space::Context.new(**options)
            return self if local_context == context

            xyz = context.chromatic_adaptation_transform.adapt(
              to_xyz,
              target_white: context.white_point,
            )

            color = coerce(Physiological::XYZ.from_intermediate(*xyz, **context.to_h))
            color.instance_variable_set(:@local_context, context)
            color
          end

          private

          def initialize_context!(**options)
            chromatic_adaptation_transform = options.fetch(
              :chromatic_adaptation_transform,
              options.fetch(
                :cat,
                self.class.native_context&.chromatic_adaptation_transform,
              ),
            )

            cone_transform = options.fetch(
              :cone_transform,
              self.class.native_context&.cone_transform,
            )

            illuminant = options.fetch(
              :illuminant,
              self.class.native_context&.illuminant,
            )

            observer = options.fetch(
              :observer,
              self.class.native_context&.observer,
            )

            return unless chromatic_adaptation_transform || cone_transform || illuminant || observer

            @local_context = Space::Context.new(
              chromatic_adaptation_transform:,
              cone_transform:,
              illuminant:,
              observer:,
            )
          end
        end
      end
    end
  end
end
