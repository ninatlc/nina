# frozen_string_literal: true

require 'toritori'
require 'nina/assembler'
require 'nina/builder'

require_relative 'nina/version'

module Nina
  class Error < StandardError; end

  module ClassMethods
    def builders
      @builders ||= {}
    end

    def builders=(other)
      @builders = other
    end

    def builder(name, produces: Class.new, &block)
      builders[name] = Nina::Builder.new(name, abstract_factory: produces, &block)
      define_singleton_method(:"#{name}_builder") { builders[name] }
    end

    def inherited(subclass)
      super
      subclass.builders = builders.transform_values do |builder|
        Nina::Builder.copy(builder)
      end
    end
  end

  def self.included(receiver)
    receiver.extend ClassMethods
  end
end
