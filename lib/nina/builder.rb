# frozen_string_literal: true

# This should be a kind of factory that creates complex objects
# from simple ones. It should use torirori to create objects.
# It also enriches objects with some methods that make them more
# like linked lists.
module Nina
  # Generates module that adds support for objects creation
  class Builder
    attr_reader :name, :abstract_factory, :def_block

    class Initialization < BasicObject
      def initialize(list)
        @list = list
        @atts = {}
      end

      def method_missing(method, *args, **kwargs, &block)
        return super unless @list.include?(method)

        @atts[method] = [args, kwargs, block]
      end

      def respond_to_missing?(method, include_private = false)
        @list.include?(method) || super
      end

      def to_h
        @atts
      end
    end

    module ClassMethods
      def list
        @list ||= []
      end

      def list=(other)
        @list = other.dup
      end

      def inherited(subclass)
        super
        subclass.list = list
      end

      def factory(name, *args, **kwargs, &block)
        list << name
        super
      end
    end

    def self.copy(builder)
      new(builder.name, abstract_factory: builder.abstract_factory)
    end

    def initialize(name, abstract_factory: nil, &def_block)
      @name = name
      @def_block = def_block
      @abstract_factory = abstract_factory.include(Toritori).extend(ClassMethods)
      @abstract_factory.class_eval(&def_block) if def_block
      @builder = Assembler.new(@abstract_factory)
    end

    def wrap(&block)
      yield initialization = Initialization.new(@abstract_factory.factories.keys) if block

      @builder.inject(initialization.to_h)
    end

    def nest(&block)
      yield initialization = Initialization.new(@abstract_factory.factories.keys) if block

      @abstract_factory.list.reverse!
      @builder.inject(initialization.to_h)
    end

    def subclass(&def_block)
      return unless def_block

      @abstract_factory = Class.new(abstract_factory)
      @abstract_factory.class_eval(&def_block)
      @builder = Assembler.new(@abstract_factory)
    end
  end
end
