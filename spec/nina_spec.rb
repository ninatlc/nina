# frozen_string_literal: true

Params = Class.new
Query = Class.new
Command = Class.new
BQ = Class.new

A = Struct.new(:a)
B = Struct.new(:b)
C = Struct.new(:c)

RSpec.describe Nina do
  it 'has a version number' do
    expect(Nina::VERSION).not_to be nil
  end

  vars do
    abstract_factory do
      Class.new do
        include Nina

        queue :main do
          factory :params, produces: Params
          factory :query, produces: Query
          factory :command, produces: Command
        end

        queue :secondary do
          factory :params, produces: A
          factory :query, produces: B
          factory :command, produces: C

          params_factory.subclass do
            attr_reader :only

            def initialize(a, only:, &block)
              super(a)
              @only = only
              @block = block
            end

            def call(a)
              @block.call(a)
            end
          end
        end
      end
    end
  end

  describe 'concrete factory' do
    it 'handles classes' do
      expect(abstract_factory).to respond_to :main_queue
      factory = abstract_factory.main_queue
      expect(factory).to be_a Nina::Factory
      expect(factory.base_class.list).to eq %i[params query command]
    end

    it 'simply creates instances' do
      factory = abstract_factory.main_queue
      instance = factory.create
      expect(instance).to be_a Command
      expect(instance.query).to be_a Query
      expect(instance.params).to be_a Params
      expect(instance.params).to eq instance.query.params
    end

    it 'creates instances with custom init' do
      factory = abstract_factory.secondary_queue
      instance = factory.create do |b|
        b.params(1, only: :me) { |v| v * 2 }
        b.query(2)
        b.command(3)
      end
      expect(instance.params.a).to eq 1
      expect(instance.query.b).to eq 2
      expect(instance.c).to eq 3
      expect(instance.a).to eq 1
      expect(instance.b).to eq 2
      expect(instance.c).to eq 3
      expect(instance.only).to eq :me
      expect(instance.params.call(3)).to eq 6
    end
  end
end
