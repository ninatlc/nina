# frozen_string_literal: true

require 'toritori'
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

  def self.included(receiver)
    receiver.extend ClassMethods
  end
end
