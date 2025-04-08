# frozen_string_literal: true

module Sai
  module Enum
    module CacheStore
      extend Enum

      value(:memory) do
        Sai::Cache::LRUStore
      end

      value(:null) do
        Sai::Cache::NullStore
      end
    end
  end
end
