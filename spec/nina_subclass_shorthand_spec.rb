# frozen_string_literal: true

ShorthandParams = Struct.new(:a)
ShorthandQuery = Struct.new(:b)
ShorthandCommand = Struct.new(:c)

class CustomShorthandQuery < ShorthandQuery
  def custom
    :customization
  end
end

class CustomShorthandCommand < ShorthandCommand
  def call(echo)
    echo
  end
end

RSpec.describe Nina do
  vars do
    abstract_factory do
      Class.new do
        include Nina

        builder :secondary do
          factory :params, produces: ShorthandParams
          factory :query, produces: ShorthandQuery
          factory :command, produces: ShorthandCommand

          params do
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

          query CustomShorthandQuery

          command CustomShorthandCommand do
            # subclass CustomShorthandCommand
            def call(echo)
              [super, super]
            end
          end
        end
      end
    end
  end

  it 'handles classes' do
    expect(abstract_factory).to respond_to :secondary_builder
    builder = abstract_factory.secondary_builder
    expect(builder).to be_a Nina::Builder
    instance = builder.wrap(delegate: true) do |b|
      b.params(1, only: :me) { |v| v * 2 }
      b.query(2)
      b.command(3)
    end
    expect(instance.params.a).to eq 1
    expect(instance.query.b).to eq 2
    expect(instance.query.custom).to eq :customization
    expect(instance.c).to eq 3
    expect(instance.a).to eq 1
    expect(instance.b).to eq 2
    expect(instance.call(:no)).to eq %i[no no]
    expect(instance.only).to eq :me
    expect(instance.params.call(3)).to eq 6
  end
end
