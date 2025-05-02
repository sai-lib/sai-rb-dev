# frozen_string_literal: true

module Sai
  module Space
    module Core
      module Configuration
        class << self
          private

          def included(base)
            super

            base.extend Sai::Core::Concurrency
            base.extend ClassMethods
          end
        end

        module ClassMethods
          def abstract_space?
            concurrent_instance_variable_fetch(:@abstract_space, false)
          end

          protected

          def abstract_space
            mutex.synchronize { @abstract_space = true }
          end

          def identified_as(identifier)
            mutex.synchronize { @identifier = identifier }
          end

          def implements(model)
            unless model.is_a?(Model::Definition)
              raise TypeError, "`model` is invalid. Expected `Sai::Model::Definition`, got: #{model.inspect}"
            end

            mutex.synchronize { @model = model }

            model.implement(self)
          end

          private

          def inherited(subclass)
            super

            subclass.send(:mutex).synchronize { subclass.instance_variable_set(:@model, model) }
          end
        end
      end
    end
  end
end
