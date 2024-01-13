# frozen_string_literal: true

module Nina
  class Builder
    # Utility to get user defined callbacks
    class Generator
      include Enumerable

      attr_reader :initialization, :callbacks

      def initialize(abstract_factory, callbacks = nil)
        @abstract_factory = abstract_factory
        @initialization = Builder::Initialization.new(@abstract_factory.build_order_list)
        @callbacks = callbacks&.copy || Builder::Callbacks.new(@abstract_factory.build_order_list)
      end

      def each(&block)
        to_enum.each(&block)
      end

      def to_enum
        Enumerator.new do |y|
          @abstract_factory.build_order_list.each do |name|
            object = create_object(name)
            y << [name, object]
            callbacks.to_h[name].each { |c| c.call(object) } if callbacks&.to_h&.key?(name)
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
