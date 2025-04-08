# frozen_string_literal: true

module Sai
  module Cache
    autoload :LRUStore,  'sai/cache/lru_store'
    autoload :NullStore, 'sai/cache/null_store'
    autoload :Store,     'sai/cache/store'
  end
end
