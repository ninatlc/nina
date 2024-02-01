# frozen_string_literal: true

Params = Class.new
Query = Class.new
Command = Class.new

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

        builder :main do
          factory :params, produces: Params
          factory :query, produces: Query
          factory :command, produces: Command
        end

        builder :secondary do
          factory :params, produces: A
          factory :query, produces: B
          factory :command, produces: C

          params_factory.subclass do
            attr_reader :only

            def initialize(var, only:, &block)
              super(var)
              @only = only
              @block = block
            end

            def call(var)
              @block.call(var)
            end
          end
        end
      end
    end
  end

  describe 'build using wrapping strategy with delegation' do
    it 'simply creates instances' do
      builder = abstract_factory.main_builder
      instance = builder.wrap(delegate: true) do |b|
        b.params
        b.query
        b.command
      end
      expect(instance).to be_a Command
      expect(instance.query).to be_a Query
      expect(instance.params).to be_a Params
      expect(instance.params).to eq instance.query.params
    end

    it 'creates new instances every time' do
      builder = abstract_factory.main_builder
      instance = builder.wrap(delegate: true) do |b|
        b.params
        b.query
        b.command
      end
      instance2 = builder.wrap(delegate: true, &:command)
      expect(instance.object_id).to_not eq(instance2.object_id)
    end

    it 'creates instances with custom init' do
      builder = abstract_factory.secondary_builder
      instance = builder.wrap(delegate: true) do |b|
        b.params(1, only: :me) { |v| v * 2 }
        b.query(2)
        b.command(3)
      end
      predecessors = instance.predecessors
      expect(instance.params.a).to eq 1
      expect(instance.query.b).to eq 2
      expect(instance.c).to eq 3
      expect(instance.a).to eq 1
      expect(instance.b).to eq 2
      expect(instance.c).to eq 3
      expect(predecessors.to_a).to eq [instance.query, instance.params]
      expect(instance.only).to eq :me
      expect(instance.params.call(3)).to eq 6
    end
  end

  describe 'build using nesting strategy without delegation' do
    it 'simply creates instances' do
      builder = abstract_factory.main_builder
      instance = builder.wrap do |b|
        b.params
        b.query
        b.command
      end
      expect(instance).to be_a Command
      expect(instance.query).to be_a Query
      expect(instance.query.params).to be_a Params
    end

    it 'creates instances with custom init' do
      builder = abstract_factory.secondary_builder
      instance = builder.wrap do |b|
        b.params(1, only: :me) { |v| v * 2 }
        b.query(2)
        b.command(3)
      end
      expect(instance.c).to eq 3
      expect(instance.query.b).to eq 2
      expect(instance.query.params.a).to eq 1
      expect(instance.query.params.only).to eq :me
      expect(instance.query.params.call(3)).to eq 6
    end
  end
end
