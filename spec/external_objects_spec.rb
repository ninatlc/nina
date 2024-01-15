# frozen_string_literal: true

ExternalParams = Struct.new(:a)
ExternalQuery = Struct.new(:b)
ExternalCommand = Struct.new(:c)

RSpec.describe Nina do
  describe '#def_reader' do
    it 'handles external objects' do
      params = ExternalParams.new(:a)
      query = ExternalQuery.new(:b)
      command = ExternalCommand.new(:c)

      Nina.def_reader(:query_link, on: command, to: query, delegate: false)
      Nina.def_reader(:query_link, on: params, to: query, delegate: false)
      expect(command.query_link).to eq(query)
      expect(params.query_link).to eq(query)
    end
  end

  describe '#link' do
    it 'defines accessors on collection of objects' do
      params = ExternalParams.new(:a)
      query = ExternalQuery.new(:b)
      command = ExternalCommand.new(:c)

      setup = { params: params, query: query, command: command }

      Nina.link(setup)
      expect(params.query).to eq(query)
      expect(params.query.command).to eq(command)
      expect(params.predecessor).to eq(query)
      expect(query.predecessor).to eq(command)
      expect { params.no_method }.to raise_error(NoMethodError)
    end

    it 'defines accessors on collection of objects and delegates to predecessor' do
      params = ExternalParams.new(:a)
      query = ExternalQuery.new(:b)
      command = ExternalCommand.new(:c)

      setup = { params: params, query: query, command: command }

      Nina.link(setup, delegate: true)
      expect(params.b).to eq(:b)
      expect(params.c).to eq(:c)
      expect(params.command).to eq(command)
      expect { params.no_method }.to raise_error(NoMethodError)
    end
  end

  describe '#reverse_link' do
    it 'defines accessors on collection of objects' do
      params = ExternalParams.new(:a)
      query = ExternalQuery.new(:b)
      command = ExternalCommand.new(:c)

      setup = { params: params, query: query, command: command }

      Nina.reverse_link(setup)
      expect(command.query).to eq(query)
      expect(command.query.params).to eq(params)
      expect(command.predecessor).to eq(query)
      expect(query.predecessor).to eq(params)
      expect { command.no_method }.to raise_error(NoMethodError)
    end

    it 'defines accessors on collection of objects' do
      params = ExternalParams.new(:a)
      query = ExternalQuery.new(:b)
      command = ExternalCommand.new(:c)

      setup = { params: params, query: query, command: command }

      Nina.reverse_link(setup, delegate: true)
      expect(command.a).to eq(:a)
      expect(command.b).to eq(:b)
      expect(command.params).to eq(params)
      expect { command.no_method }.to raise_error(NoMethodError)
    end
  end
end
