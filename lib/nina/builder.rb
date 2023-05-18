module Nina
  # Generates module that adds support for objects creation
  class Builder
    module MethodMissingDelegation
      def method_missing(name, *attrs, &block)
        return super unless methods.detect { |m| m == :__predecessor }

        public_send(__predecessor).public_send(name, *attrs, &block)
      end

      def respond_to_missing?(method_name, _include_private = false)
        return super unless methods.detect { |m| m == :__predecessor }

        public_send(__predecessor).respond_to?(method_name)
      end
    end

    def self.def_accessor(accessor, on:, to:, delegate: false)
      on.define_singleton_method(:__predecessor) { accessor }
      on.define_singleton_method(accessor) { to }
      on.extend(MethodMissingDelegation) if delegate
    end

    def initialize(queue)
      @queue = queue
    end

    def build(initialization = {})
      @queue.list.each.with_index(-1).inject(nil) do |prev, (name, idx)|
        object = create_object(name, initialization)
        next object if prev.nil?

        self.class.def_accessor(@queue.list[idx], on: object, to: prev, delegate: true)
        object
      end
    end

    private

    def create_object(name, initialization = {})
      return @queue.send("#{name}_factory").create if initialization[name].nil?

      args, kwargs, block = initialization[name]
      @queue.send("#{name}_factory").create(*args, **kwargs, &block)
    end
  end
end
