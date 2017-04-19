# frozen_string_literal: true

require 'spec_helper'

RSpec.describe DvelpApiResponse::IncludeItemParser do
  describe '#object_name' do
    context 'included_item is a hash' do
      it 'returns the first hash key' do
        included_item = { brands: [:venues] }

        object = DvelpApiResponse::IncludeItemParser.new(included_item)

        expect(object.object_name).to eq(:brands)
      end
    end

    context 'included_item is NOT a hash' do
      it 'returns an empty array' do
        included_item = :brand

        object = DvelpApiResponse::IncludeItemParser.new(included_item)

        expect(object.object_name).to eq(included_item)
      end
    end
  end

  describe '#nested_includes' do
    context 'included_item is a hash' do
      it 'returns the hash values' do
        included_item = { brands: [:venues] }

        object = DvelpApiResponse::IncludeItemParser.new(included_item)

        expect(object.nested_includes).to eq(included_item.values[0])
      end
    end

    context 'included_item is NOT a hash' do
      it 'returns an empty array' do
        included_item = [:brand]

        object = DvelpApiResponse::IncludeItemParser.new(included_item)

        expect(object.nested_includes).to be_empty
      end
    end
  end
end
