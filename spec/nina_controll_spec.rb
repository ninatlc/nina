# frozen_string_literal: true

ControllParams = Struct.new(:a)
ControllQuery = Struct.new(:b)
ControllCommand = Struct.new(:c)

RSpec.describe Nina do
  vars do
    abstract_factory do
      Class.new do
        include Nina

        builder :main do
          factory :params, produces: ControllParams
          factory :query, produces: ControllQuery
          factory :command, produces: ControllCommand
        end
      end
    end
  end

  context 'when building' do
    it 'allows to controll the building process' do
      builder = abstract_factory.main_builder
      builder_with_callbacks = builder.with_callbacks do |c|
        c.params { _1.a = 1 }
        c.query { _1.b = 2 }
      end
      instance = builder_with_callbacks.wrap do |b|
        b.params
        b.query
        b.command(3)
      end
      expect(instance.query.params.a).to eq 1
      expect(instance.query.b).to eq 2
      expect(instance.c).to eq 3
    end
  end

  context 'multiple callbacks' do
    it 'aggregates callbacks' do
      builder = abstract_factory.main_builder
      builder_with_callbacks = builder.with_callbacks do |c|
        c.params { _1.a = 1 }
        c.params { _1.a += 3 }
        c.params { _1.a += 2 }
        c.query { _1.b = 2 }
      end
      instance = builder_with_callbacks.wrap do |b|
        b.params
        b.query
        b.command
      end
      expect(instance.query.params.a).to eq 6
      expect(instance.query.b).to eq 2
      expect(instance.c).to eq nil
    end
  end

  context 'with_callbacks' do
    it 'should be chainable' do
      copied = nil
      builder = abstract_factory.main_builder
      builder = builder.with_callbacks do |c|
        c.params { _1.a = 1 }
      end
      builder = builder.with_callbacks do |c|
        c.params { copied = _1.a }
      end
      builder.wrap do |b|
        b.params
        b.query
        b.command
      end
      expect(copied).to eq(1)
    end
  end
end
