# frozen_string_literal: true

module Nina
  class Builder
    # Utility to get user defined callbacks
    class Callbacks < Initialization
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
    end
  end
end
