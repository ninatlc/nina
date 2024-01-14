# frozen_string_literal: true

module Nina
  class Builder
    # A way to call methods from initalization proc on base_class
    class Initialization < BasicObject
      def initialize(abstract_factory, atts = {})
        @abstract_factory = abstract_factory
        @allow_list = @abstract_factory.factories.keys
        @atts = atts
      end

      def method_missing(method, *args, **kwargs, &block)
        return super unless @allow_list.include?(method)

        @atts[method] ||= @abstract_factory.create(method, *args, **kwargs, &block)
      end

      def respond_to_missing?(method, _include_private = false)
        @allow_list.include?(method)
      end

      def to_h
        @atts.dup
      end
    end
  end
end
