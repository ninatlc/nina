# frozen_string_literal: true

require 'nina/builder/initialization'
require 'nina/builder/callbacks'

# This should be a kind of factory that creates complex objects
# from simple ones. It should use torirori to create objects.
# It also enriches objects with some methods that make them more
# like linked lists.
module Nina
  # Generates module that adds support for objects creation
  class Builder
    attr_reader :name, :abstract_factory, :def_block, :callbacks

    # Definaes support methods and variables for concrete builder
    module ClassMethods
      def factory(name, *args, **kwargs, &block)
        super
        define_singleton_method(name) do |klass = nil, &definition|
          factories[__method__].subclass(produces: klass, &definition)
        end
      end
    end

    def initialize(name, abstract_factory: nil, callbacks: nil, &def_block)
      @name = name
      @def_block = def_block
      @abstract_factory = abstract_factory.include(Toritori).extend(ClassMethods)
      @abstract_factory.class_eval(&def_block) if def_block
      @initialization = Builder::Initialization.new(self)
      @callbacks = callbacks&.copy || Callbacks.new(@abstract_factory.factories.keys)
      @observers = []
    end

    def add_observer(observer)
      @observers << observer
    end

    def copy
      new_builder = self.class.new(name, abstract_factory: abstract_factory, callbacks: @callbacks)
      @observers.each { |observer| new_builder.add_observer(observer) }
      new_builder
    end

    def with_callbacks(&block)
      yield @callbacks if block

      copy
    end

    def nest(delegate: false, &block)
      yield @initialization if block

      Nina.link(@initialization.to_h, delegate: delegate)
    end

    def wrap(delegate: false, &block)
      yield @initialization if block

      Nina.reverse_link(@initialization.to_h, delegate: delegate)
    end

    def subclass(&def_block)
      return unless def_block

      @abstract_factory = Class.new(abstract_factory)
      @abstract_factory.class_eval(&def_block)
      @initialization = Builder::Initialization.new(self)
      @callbacks = callbacks&.copy || Callbacks.new(@abstract_factory.build_order_list)
    end

    private

    def callbacks_for(name)
      return [] unless @callbacks

      @callbacks.to_h.fetch(name, [])
    end

    def update(name, object)
      callbacks_for(name).each { |c| c.call(object) }
      @observers.each do |observer|
        observer.public_send(:"on_#{name}_created", object, @name) if observer.respond_to?(:"on_#{name}_created")
      end
    end
  end
end
