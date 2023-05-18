# frozen_string_literal: true

# This should be a kind of factory that creates complex objects
# from simple ones. It should use torirori to create objects.
# It also enriches objects with some methods that make them more
# like linked lists.
module Nina
  # Generates module that adds support for objects creation
  class Factory
    attr_reader :name, :base_class

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

      def factory(name, *args, **kwargs, &block)
        list << name
        super
      end
    end

    def initialize(name, base_class: nil, &block)
      @name = name
      @base_class = base_class.include(Toritori).extend(ClassMethods)
      @base_class.class_eval(&block) if block
      @builder = Builder.new(@base_class)
    end

    def create(&block)
      yield initialization = Initialization.new(@base_class.factories.keys) if block

      @builder.build(initialization.to_h)
    end
  end
end
