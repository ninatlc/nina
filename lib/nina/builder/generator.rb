# frozen_string_literal: true

module Nina
  class Builder
    # Utility to get user defined callbacks
    class Generator
      attr_reader :initialization

      def initialize(abstract_factory)
        @abstract_factory = abstract_factory
        @initialization = Builder::Initialization.new(@abstract_factory.build_order_list)
      end

      def each
        Enumerator.new do |y|
          @abstract_factory.build_order_list.reverse_each do |name|
            y << [name, create_object(name)]
          end
        end
      end

      def create_object(name)
        return @abstract_factory.create(name) if initialization.to_h[name].nil?

        args, kwargs, block = initialization.to_h[name]
        @abstract_factory.create(name, *args, **kwargs, &block)
      end
    end
  end
end
