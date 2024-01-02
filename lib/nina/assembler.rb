# frozen_string_literal: true

require 'nina/builder/initialization'
require 'nina/builder/callbacks'

module Nina
  # Generates module that adds support for objects creation
  class Assembler
    include Observable

    attr_reader :initialization, :callbacks

    def initialize(abstract_factory, callbacks = nil)
      @abstract_factory = abstract_factory
      @initialization = Builder::Initialization.new(@abstract_factory.build_order_list)
      @callbacks = callbacks&.copy || Builder::Callbacks.new(@abstract_factory.build_order_list)
    end

    def inject(build_order, delegate: false)
      build_order.each.with_index(-1).inject(nil) do |prev, (name, idx)|
        object = create_object(name, initialization)
        setup_relation(object, prev, name, build_order[idx], delegate)
        changed
        notify_observers(name, object)
        object
      end
    end

    private

    def setup_relation(object, prev, name, accessor, delegate)
      Nina.def_accessor(accessor, on: object, to: prev, delegate: delegate) if prev
      callbacks.to_h[name].each { |c| c.call(object) } if callbacks&.to_h&.key?(name)
    end

    def create_object(name, initialization = {})
      return @abstract_factory.create(name) if initialization.to_h[name].nil?

      args, kwargs, block = initialization.to_h[name]
      @abstract_factory.create(name, *args, **kwargs, &block)
    end
  end
end
