# frozen_string_literal: true

class InheritParams
  def self.create(data:)
    new(data)
  end

  def initialize(data)
    @data = data
  end
end

RSpec.describe Nina do
  vars do
    abstract_factory do
      Class.new do
        include Toritori

        factory :params, produces: InheritParams do |data|
          create(data: data)
        end

        params_factory.subclass do
          def get
            @data + 5
          end
        end
      end
    end
    child_factory do
      Class.new(abstract_factory) do
        params_factory.subclass.init do |data, var|
          new(data, var)
        end

        params_factory.subclass do
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

  describe 'concrete factory' do
    it 'handles classes' do
      expect(child_factory).to respond_to :params_factory
      factory = child_factory.params_factory
      expect(factory).to be_a Toritori::Factory
      # expect(factory.base_class).to eq InheritParams
      expect(factory.base_class <= InheritParams).to be_truthy
    end

    it 'simply creates instances' do
      factory = child_factory.params_factory
      expect { factory.create }.to raise_error ArgumentError
      instance = factory.create(2, 9)
      expect(instance.class.superclass.superclass).to eq InheritParams
      expect(instance.get).to eq 16
    end
  end
end
