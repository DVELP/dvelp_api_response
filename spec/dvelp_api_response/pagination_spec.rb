# frozen_string_literal: true

require 'spec_helper'

RSpec.describe DvelpApiResponse::Pagination do
  describe '#as_hash' do
    it 'returns a hash' do
      create(:test_record)
      resource = TestRecord.page
      object = DvelpApiResponse::Pagination.new(resource)

      attributes = { current_page: resource.count,
                     total_pages: resource.count,
                     total_count: resource.count }

      expect(object.as_hash).to eq(pagination: attributes)
    end
  end

  describe '#attributes' do
    it 'returns a hash of attributes' do
      create(:test_record)
      resource = TestRecord.page
      object = DvelpApiResponse::Pagination.new(resource)

      attributes = { current_page: resource.count,
                     total_pages: resource.count,
                     total_count: resource.count }

      expect(object.attributes).to eq(attributes)
    end

    context 'object has previous page' do
      it 'includes :prev_page in attributes' do
        resources = create_list(:test_record, 2)
        resource = TestRecord.page(resources.count).per(1)
        object = DvelpApiResponse::Pagination.new(resource)

        attributes = { current_page: resources.count,
                       total_pages: resources.count,
                       total_count: resources.count,
                       prev_page: resource.count }

        expect(object.attributes).to eq(attributes)
      end
    end

    context 'object has next page' do
      it 'includes :next_page in attributes' do
        resources = create_list(:test_record, 2)
        resource = TestRecord.page(1).per(1)
        object = DvelpApiResponse::Pagination.new(resource)

        attributes = { current_page: resource.count,
                       total_pages: resources.count,
                       total_count: resources.count,
                       next_page: resources.count }

        expect(object.attributes).to eq(attributes)
      end
    end
  end

  describe 'global_attributes' do
    let(:global_attributes) do
      {
        current_page: object.current_page,
        total_pages: object.total_pages,
        total_count: object.total_count
      }
    end

    subject { pagination.global_attributes }

    it 'returns a hash of attributes that persist' do
      create(:test_record)
      resource = TestRecord.page
      object = DvelpApiResponse::Pagination.new(resource)

      attributes = { current_page: resource.count,
                     total_pages: resource.count,
                     total_count: resource.count }

      expect(object.global_attributes).to eq(attributes)
    end
  end

  describe '#prev_page' do
    it 'returns a hash containing previous page attributes' do
      create_list(:test_record, 2)
      resource = TestRecord.page(2).per(1)
      object = DvelpApiResponse::Pagination.new(resource)

      expect(object.prev_page).to eq(prev_page: resource.count)
    end
  end

  describe '#next_page' do
    it 'returns a hash containing previous page attributes' do
      resources = create_list(:test_record, 2)
      resource = TestRecord.page(1).per(1)
      object = DvelpApiResponse::Pagination.new(resource)

      expect(object.next_page).to eq(next_page: resources.count)
    end
  end
end
