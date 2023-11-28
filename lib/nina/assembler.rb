# frozen_string_literal: true

module Nina
  # Generates module that adds support for objects creation
  class Assembler
    def initialize(abstract_factory)
      @abstract_factory = abstract_factory
    end

    def inject(build_order, initialization = {}, callbacks: nil, delegate: false)
      build_order.each.with_index(-1).inject(nil) do |prev, (name, idx)|
        object = create_object(name, initialization)
        Nina.def_accessor(build_order[idx], on: object, to: prev, delegate: delegate) if prev
        callbacks[name].each { |c| c.call(object) } if callbacks&.key?(name)
        object
      end
    end

    private

    def create_object(name, initialization = {})
      return @abstract_factory.factories[name].create if initialization[name].nil?

      args, kwargs, block = initialization[name]
      @abstract_factory.factories[name].create(*args, **kwargs, &block)
    end
  end
end
