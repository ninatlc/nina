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

  it 'handles classes' do
    expect(abstract_factory).to respond_to :main_builder
    expect(abstract_factory).to respond_to :secondary_builder
    builder = abstract_factory.main_builder
    expect(builder).to be_a Nina::Builder
    expect(builder.abstract_factory.build_order_list).to eq %i[params query command]
  end
end
