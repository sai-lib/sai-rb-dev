# frozen_string_literal: true

module Sai
  module Core
    module Cache
      class LRUStore < Store
        Node = Struct.new(:key, :value, :mem_size, :prev, :next)

        def initialize(**options)
          super
          @bytes     = 0
          @max_bytes = options.fetch(:max_size, 2000)

          @head = Node.new(nil, nil, 0, nil, nil)
          @tail = Node.new(nil, nil, 0, nil, nil)

          @head.next = @tail
          @tail.prev = @head
        end

        def clear
          mutex.synchronize do
            @store.clear
            @bytes = 0

            @head.next = @tail
            @tail.prev = @head
          end
        end

        protected

        def read_by_key(key)
          mutex.synchronize do
            node = @store[key]
            return nil unless node

            move_to_front(node)

            node.value
          end
        end

        def write_by_key(key, value)
          mutex.synchronize do
            value      = deep_freeze(value)
            value_size = Marshal.dump(value).bytesize

            remove_node(@store[key]) if @store.key?(key)

            node = Node.new(key, value, value_size, nil, nil)

            add_to_front(node)
            @store[key] = node
            @bytes += value_size

            evict!
          end
        end

        private

        def add_to_front(node)
          node.next = @head.next
          node.prev = @head

          @head.next.prev = node
          @head.next = node
        end

        def evict!
          remove_node(@tail.prev) while @bytes > @max_bytes && @tail.prev != @head
        end

        def move_to_front(node)
          node.prev.next = node.next
          node.next.prev = node.prev

          add_to_front(node)
        end

        def remove_node(node)
          node.prev.next = node.next
          node.next.prev = node.prev

          @bytes -= node.mem_size
          @store.delete(node.key)
        end
      end
    end
  end
end
