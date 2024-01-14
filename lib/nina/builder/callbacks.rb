# frozen_string_literal: true

module Nina
  class Builder
    # Utility to get user defined callbacks
    class Callbacks
      def initialize(allow_list, atts = {})
        @allow_list = allow_list
        @atts = atts
      end

      def copy
        Callbacks.new(@allow_list, to_h.dup)
      end

      def method_missing(method, *args, **kwargs, &block)
        return super unless @allow_list.include?(method)

        @atts[method] unless block
        @atts[method] ||= []
        @atts[method] << block
      end

      def respond_to_missing?(method, include_private = false)
        super
      end

      def to_h
        @atts
      end
    end
  end
end
