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

  describe '#compacted hashes' do
    it 'compacts hashes with same key values' do
      nested_includes = ['brand.tiers', 'brand.venues.category']

      object = DvelpApiResponse::IncludeParser.new(nested_includes)

      expected_output = [
        { 'brand' => ['tiers',
                      { 'venues' => 'category' }] }
      ]

      expect(object.send(:compacted_hashes)).to eq(expected_output)
    end
  end

  describe '#base_level_includes' do
    it 'returns an array without any hashes' do
      includes = ['brand', 'venues.category']

      object = DvelpApiResponse::IncludeParser.new(includes)

      expect(object.send(:base_level_includes)).to eq(['brand'])
    end
  end

  describe '#nested_includes' do
    it 'returns an array with only hashes' do
      includes = ['brand', 'venues.category']

      object = DvelpApiResponse::IncludeParser.new(includes)

      expect(object.send(:nested_includes)).to eq(['venues' => 'category'])
    end
  end

  describe '#formatted_array' do
    it 'loops through the includes and parses them' do
      includes = ['brand', 'venues.category']

      object = DvelpApiResponse::IncludeParser.new(includes)

      expect(object.send(:formatted_array).count).to eq 2
      expect(object.send(:formatted_array).first).to be_a(String)
    end
  end

  describe '#format_string(include_string)' do
    it 'turns strings into arrays and hashes' do
      includes = ['brand', 'venues.category']
      include_string = 'venues.category'

      object = DvelpApiResponse::IncludeParser.new(includes)

      expect(object.send(:format_string, include_string))
        .to eq('venues' => 'category')
    end
  end
end
