# frozen_string_literal: true

class InheritParams
  def self.create(data:)
    new(data)
  end

  def initialize(data)
    @data = data
  end
end
InheritQuery = Class.new
InheritCommand = Class.new
BBB = Class.new

RSpec.describe Nina do
  vars do
    abstract_factory do
      Class.new do
        include Nina

        builder :main do
          factory :params, produces: InheritParams, creation_method: :create
          factory :query, produces: InheritQuery
          factory :command, produces: InheritCommand

          params_factory.subclass do
            def get
              @data + 5
            end
          end
        end
      end
    end
    child_abstract_factory do
      Class.new(abstract_factory) do
        main_builder.subclass do
          params_factory.subclass(creation_method: :new) do
            def initialize(data, var)
              @data = data
              @var = var
            end

            def get
              super + @var
            end
          end
        end
      end
    end
  end

  describe 'concrete factory' do
    it 'handles classes' do
      expect(child_abstract_factory).to respond_to :main_builder
      builder = child_abstract_factory.main_builder
      expect(builder).to be_a Nina::Builder
      expect(builder.abstract_factory.build_order_list).to eq %i[params query command]
    end

    it 'simply creates instances' do
      builder = child_abstract_factory.main_builder
      expect { builder.nest }.to raise_error ArgumentError
      expect(builder.abstract_factory.build_order_list).to eq %i[params query command]
      instance = builder.wrap do |b|
        b.params(2, 9)
      end
      expect(instance.query.params.class.superclass.superclass).to eq InheritParams
      expect(instance.query.params.get).to eq 16
    end
  end
end
