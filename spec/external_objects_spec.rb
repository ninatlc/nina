# frozen_string_literal: true

ExternalParams = Struct.new(:a)
ExternalQuery = Struct.new(:b)
ExternalCommand = Struct.new(:c)

RSpec.describe Nina do
  describe '#def_accessor' do
    it 'handles external objects' do
      params = ExternalParams.new(:a)
      query = ExternalQuery.new(:b)
      command = ExternalCommand.new(:c)

      Nina.def_accessor(:query_link, on: command, to: query, delegate: false)
      Nina.def_accessor(:query_link, on: params, to: query, delegate: false)
      expect(command.query_link).to eq(query)
      expect(params.query_link).to eq(query)
    end
  end

  describe '#linked_list' do
    it 'defines accessors on collection of objects' do
      params = ExternalParams.new(:a)
      query = ExternalQuery.new(:b)
      command = ExternalCommand.new(:c)

      setup = { params: params, query: query, command: command }

      Nina.linked_list(setup)
      expect(command.query).to eq(query)
      expect(command.query.params).to eq(params)
      expect { command.no_method }.to raise_error(NoMethodError)
    end
  end
end
