# frozen_string_literal: true

require 'toritori'
require 'observer'
require 'nina/assembler'
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
      if (prev = predecessors.detect { |o| o.public_methods.include?(name) })
        prev.public_send(name, *attrs, **kwargs, &block)
      else
        super
      end
    end

    def respond_to_missing?(method_name, _include_private = false)
      public_methods.detect { |m| m == :predecessor_name } || super
    end

    def predecessors
      @predecessors ||= begin
        obj = self
        [].tap do |list|
          list << obj = obj.public_send(obj.predecessor_name) while obj.methods.detect { |m| m == :predecessor_name }
        end
      end
    end
  end

  def self.included(receiver)
    receiver.extend ClassMethods
  end

  def self.def_accessor(accessor, on:, to:, delegate: false)
    on.define_singleton_method(accessor) { to }
    return unless delegate

    on.define_singleton_method(:predecessor_name) { accessor }
    on.extend(MethodMissingDelegation)
  end

  def self.linked_list(build_config, delegate: false)
    build_order = build_config.keys
    build_config.each.with_index(-1).inject(nil) do |prev, ((_, object), idx)|
      Nina.def_accessor(build_order[idx], on: object, to: prev, delegate: delegate) if prev
      object
    end
  end
end
