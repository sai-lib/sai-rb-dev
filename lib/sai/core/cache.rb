# frozen_string_literal: true

module Sai
  module Core
    module Cache
      autoload :LRUStore,  'sai/core/cache/lru_store'
      autoload :NullStore, 'sai/core/cache/null_store'
      autoload :Store,     'sai/core/cache/store'
    end
  end
end
