# frozen_string_literal: true

ObserveParams = Struct.new(:a)
ObserveQuery = Struct.new(:b)
ObserveCommand = Struct.new(:c)

RSpec.describe Nina do
  vars do
    abstract_factory do
      Class.new do
        include Nina

        builder :main do
          factory :params, produces: ObserveParams
          factory :query, produces: ObserveQuery
          factory :command, produces: ObserveCommand
        end
      end
    end
    observer do
      double(on_params_created: nil, on_query_created: nil)
    end
  end

  context 'when has defined observer' do
    it 'allows to Observe the building process' do
      builder = abstract_factory.main_builder
      builder.add_observer(observer)
      builder_with_callbacks = builder.with_callbacks do |c|
        c.params { _1.a = 1 }
        c.query { _1.b = 2 }
      end
      instance = builder_with_callbacks.wrap do |b|
        b.command(3)
      end
      expect(instance.query.params.a).to eq 1
      expect(instance.query.b).to eq 2
      expect(instance.c).to eq 3
      expect(observer).to have_received(:on_params_created).with(instance.query.params)
      expect(observer).to have_received(:on_query_created).with(instance.query)
    end
  end
end
