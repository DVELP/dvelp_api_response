# frozen_string_literal: true

require 'spec_helper'

RSpec.describe DvelpApiResponse::Distributor do
  VERSION = 1

  describe '#build_response' do
    it 'returns a hash' do
      resource = build(:test_record)
      object = DvelpApiResponse::Distributor.new(resource, VERSION, [])

      expect(object.build_response).to be_a(Hash)
    end

    it 'returns a hash of klass_name and response_hash' do
      resource = build(:test_record)
      object = DvelpApiResponse::Distributor.new(resource, VERSION, [])

      expect(object).to receive(:resource_class_as_sym)
      expect(object).to receive(:response_hash)

      object.build_response
    end

    context 'resource is not valid' do
      it 'returns nil' do
        object = DvelpApiResponse::Distributor.new(nil, VERSION, [])

        expect(object.build_response).to be_nil
      end
    end

    context 'resource is paginated' do
      it 'returns pagination hash' do
        create(:test_record)
        object = DvelpApiResponse::Distributor.new(TestRecord.page, VERSION, [])

        expect(object.build_response).to have_key(:pagination)
      end
    end
  end

  describe '#resource_is_valid?' do
    context 'resource_class does not return NilClass' do
      it 'returns true' do
        resource = build(:test_record)
        object = DvelpApiResponse::Distributor.new(resource, VERSION, [])

        expect(object.resource_is_valid?).to be_truthy
      end
    end

    context 'resource_class returns NilClass' do
      it 'returns false' do
        object = DvelpApiResponse::Distributor.new(nil, VERSION, [])

        expect(object.resource_is_valid?).to be_falsey
      end
    end
  end

  describe '#api_response_class' do
    it 'returns a class constant for the api_response' do
      resource = build(:test_record)
      object = DvelpApiResponse::Distributor.new(resource, VERSION, [])

      expect(object.api_response_class).to eq(TestRecordResponder)
    end
  end

  describe '#resource_class' do
    it 'returns the class of the resource' do
      resource = build(:test_record)
      object = DvelpApiResponse::Distributor.new(resource, VERSION, [])

      expect(object.resource_class).to eq(resource.class.name)
    end

    context 'resource is an active record relation' do
      it 'returns the class of the first item in the array' do
        test_record = create(:test_record, :with_child_records)
        resource = test_record.child_records

        object = DvelpApiResponse::Distributor.new(resource, VERSION, [])

        expect(object.resource_class).to eq(resource.first.class.name)
      end
    end
  end

  describe '#resource_class_as_sym' do
    it 'returns a symbol' do
      resource = create(:test_record)

      object = DvelpApiResponse::Distributor.new(resource, VERSION, [])

      expect(object.resource_class_as_sym).to be_a(Symbol)
    end

    context 'is a collection' do
      it 'returns the plural klass name' do
        resource = create_list(:test_record, 2)

        object = DvelpApiResponse::Distributor.new(resource, VERSION, [])

        expect(object.resource_class_as_sym).to eq(:test_records)
      end
    end

    context 'is not a collection' do
      it 'returns the singular klass name' do
        resource = create(:test_record)

        object = DvelpApiResponse::Distributor.new(resource, VERSION, [])

        expect(object.resource_class_as_sym).to eq(:test_record)
      end
    end
  end

  describe '#response_hash' do
    context 'is a collection' do
      it 'calls collection_response' do
        resource = create_list(:test_record, 2)

        object = DvelpApiResponse::Distributor.new(resource, VERSION, [])

        expect(object).to receive(:collection_response)

        object.response_hash
      end
    end

    context 'is not a collection' do
      it 'calls singular_record' do
        resource = create(:test_record)

        object = DvelpApiResponse::Distributor.new(resource, VERSION, [])

        expect(object).to receive(:singular_response)

        object.response_hash
      end
    end
  end

  describe '#collection?' do
    context 'collection is more than 1' do
      it 'returns true' do
        resource = create_list(:test_record, 2)

        object = DvelpApiResponse::Distributor.new(resource, VERSION, [])

        expect(object.collection?).to be_truthy
      end
    end

    context 'collection is eq to 1' do
      it 'returns false' do
        resource = create(:test_record)

        object = DvelpApiResponse::Distributor.new(resource, VERSION, [])

        expect(object.collection?).to be_falsey
      end
    end
  end

  describe '#collection_response' do
    it 'returns a hash' do
      resource = build_list(:test_record, 2)

      object = DvelpApiResponse::Distributor.new(resource, VERSION, [])

      expect(object.collection_response.first).to be_a(Hash)
    end

    it 'builds an array of DvelpApiResponse::ObjectBuilder objects' do
      resource = build_list(:test_record, 2)

      object = DvelpApiResponse::Distributor.new(resource, VERSION, [])

      expect(object.collection_response).to be_a(Array)
      expect(object.collection_response.count).to eq 2
    end
  end

  describe '#singular_response' do
    it 'builds an DvelpApiResponse::ObjectBuilder object' do
      resource = build(:test_record)

      object = DvelpApiResponse::Distributor.new(resource, VERSION, [])

      expect(object.singular_response).to be_a(Hash)
    end
  end

  describe '#paginated?' do
    context 'resource is a collection' do
      context 'it is not paginated' do
        it 'returns true' do
          resource = build_list(:test_record, 2)

          object = DvelpApiResponse::Distributor.new(resource, VERSION, [])

          expect(object.paginated?).to be_falsey
        end
      end

      context 'it is paginated' do
        it 'returns true' do
          create(:test_record)

          object = DvelpApiResponse::Distributor
            .new(TestRecord.page, VERSION, [])

          expect(object.paginated?).to be_truthy
        end
      end
    end

    context 'resource is not a collection' do
      it 'returns false' do
        resource = build(:test_record)

        object = DvelpApiResponse::Distributor.new(resource, VERSION, [])

        expect(object.paginated?).to be_falsey
      end
    end
  end

  describe '#pagination' do
    it 'create a new DvelpApiResponse::Pagination object' do
      object = DvelpApiResponse::Distributor.new(TestRecord.page, VERSION, [])

      expect(object.pagination).to have_key(:pagination)
    end
  end

  describe '#parsed_includes' do
    context 'root is true' do
      it 'parses the array of strings' do
        resource = build_list(:test_record, 2)

        object = DvelpApiResponse::Distributor
          .new(resource, VERSION, ['test_record.venues'])

        expect(object.parsed_includes).to include('test_record' => ['venues'])
      end
    end

    context 'root is false' do
      it 'returns the includes' do
        resource = build_list(:test_record, 2)
        includes = ['test_record.venues']

        object = DvelpApiResponse::Distributor
          .new(resource, VERSION, includes, false)

        expect(object.parsed_includes).to eq includes
      end
    end
  end
end
