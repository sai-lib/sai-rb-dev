# frozen_string_literal: true

module Sai
  module Core
    module Cache
      class NullStore < Store
        def initialize(...) # rubocop:disable Lint/MissingSuper
        end

        def [](...); end

        def []=(...); end

        def clear; end

        def count(&)
          0
        end

        def fetch(...)
          yield
        end

        def length
          0
        end
        alias size length
      end
    end
  end
end
