# frozen_string_literal: true

require 'toritori'
require 'nina/builder'

require_relative 'nina/version'

# Module that provides DSL for builders
module Nina
  class Error < StandardError; end

  # Definaes support methods and variables
  module ClassMethods
    def builders
      @builders ||= {}
    end

    def builders=(other)
      @builders = other
    end

    def builder(name, &block)
      builders[name] = Nina::Builder.new(name, abstract_factory: Class.new, &block)
      define_singleton_method(:"#{name}_builder") { builders[name] }
    end

    def inherited(subclass)
      super
      subclass.builders = builders.transform_values(&:copy)
    end
  end

  # Adds ability to delegeate methods via method_missing
  module MethodMissingDelegation
    def method_missing(name, *attrs, **kwargs, &block)
      if (prev = predecessors.lazy.detect { |o| o.public_methods.include?(name) })
        prev.public_send(name, *attrs, **kwargs, &block)
      else
        super
      end
    end

    def respond_to_missing?(method_name, _include_private = false)
      public_methods.detect { |m| m == :predecessor } || super
    end
  end

  def self.included(receiver)
    receiver.extend ClassMethods
  end

  def self.def_accessor(accessor, on:, to:, delegate: false)
    on.define_singleton_method(accessor) { to }
    on.define_singleton_method(:predecessor) { to }
    def on.predecessors
      Enumerator.new do |y|
        obj = self
        y << obj = obj.predecessor while obj.methods.detect { |m| m == :predecessor }
      end
    end
    return unless delegate

    on.extend(MethodMissingDelegation)
  end
end
