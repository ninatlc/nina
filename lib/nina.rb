# frozen_string_literal: true
require 'toritori'
require 'nina/builder'
require 'nina/factory'

require_relative "nina/version"

module Nina
  class Error < StandardError; end

  module ClassMethods
    def queues
      @queues ||= {}
    end

    def queue(name, produces: Class.new, &block)
      queues[name] = Nina::Factory.new(name, base_class: produces, &block)
      define_singleton_method(:"#{name}_queue") { queues[name] }
    end
  end

  def self.default_init
    @default_init ||= ->(*args, **kwargs, &block) { new(*args, **kwargs, &block) }
  end

  def self.included(receiver)
    receiver.extend ClassMethods
  end
end
