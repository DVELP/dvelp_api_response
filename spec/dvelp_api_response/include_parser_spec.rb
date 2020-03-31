# frozen_string_literal: true

require 'spec_helper'

RSpec.describe DvelpApiResponse::IncludeParser, type: :model do
  describe '#parsed_array' do
    it 'returns a formatted array' do
      includes = ['brand', 'brand.venues.category']

      object = DvelpApiResponse::IncludeParser.new(includes)

      parsed_array = [
        { 'brand' => [{ 'venues' => 'category' }] },
        'brand'
      ]

      expect(object.parsed_array).to eq(parsed_array)
    end
  end

  describe '#indirect_relations' do
    it 'compacts hashes with same key values' do
      nested_includes = ['brand.tiers', 'brand.venues.category']

      object = DvelpApiResponse::IncludeParser.new(nested_includes)

      expected_output = [
        { 'brand' => ['tiers',
                      { 'venues' => 'category' }] }
      ]

      expect(object.send(:indirect_relations)).to eq(expected_output)
    end
  end

  describe "#partition_relations" do
    context 'populating @direct_relations on initialize' do
      it 'builds an array without any hashes' do
        includes = ['brand', 'venues.category']

        object = DvelpApiResponse::IncludeParser.new(includes)

        expect(object.send(:direct_relations)).to eq(['brand'])
      end
    end

    context 'populating @nested_relations on initialize' do
      it 'builds an array with only hashes' do
        includes = ['brand', 'venues.category']

        object = DvelpApiResponse::IncludeParser.new(includes)

        expect(object.send(:nested_relations)).to eq(['venues' => 'category'])
      end
    end
  end

  describe '#relations' do
    it 'loops through the includes and parses them' do
      includes = ['brand', 'venues.category']

      object = DvelpApiResponse::IncludeParser.new(includes)

      expect(object.send(:relations).count).to eq 2
      expect(object.send(:relations).first).to be_a(String)
    end
  end

  describe '#resolve_relations(include_string)' do
    it 'turns strings into arrays and hashes' do
      includes = ['brand', 'venues.category']
      include_string = 'venues.category'

      object = DvelpApiResponse::IncludeParser.new(includes)

      expect(object.send(:resolve_relations, include_string))
        .to eq('venues' => 'category')
    end
  end
end
