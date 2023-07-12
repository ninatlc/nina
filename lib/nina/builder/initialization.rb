# frozen_string_literal: true

module Nina
  class Builder
    # A way to call methods from initalization proc on base_class
    class Initialization < BasicObject
      attr_reader :allow_list

      def initialize(allow_list, atts = {})
        @allow_list = allow_list
        @atts = atts
      end

      def method_missing(method, *args, **kwargs, &block)
        return super unless @allow_list.include?(method)

        @atts[method] = [args, kwargs, block]
      end

      def respond_to_missing?(method, include_private = false)
        @allow_list.include?(method) || super
      end

      def to_h
        @atts
      end
    end
  end
end
