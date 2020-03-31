# frozen_string_literal: true

RSpec.describe DvelpApiResponse::Base do
  VERSION = 1

  describe '#as_hash' do
    it 'calls #parse_versioned_hash' do
      test_record = create(:test_record, :with_child_records)
      versioned_hash = { "v_#{VERSION}".to_sym => [:name] }

      object = DvelpApiResponse::Base.new(test_record, VERSION, [])

      allow(object).to receive(:versioned_hash).and_return(versioned_hash)

      expect(object).to receive(:parse_versioned_hash)

      object.as_hash
    end

    it 'calls #associated_objects_to_hash' do
      test_record = create(:test_record, :with_child_records)
      versioned_hash = { "v_#{VERSION}".to_sym => [:name] }
      object = DvelpApiResponse::Base.new(test_record, VERSION, [])

      allow(object).to receive(:versioned_hash).and_return(versioned_hash)

      expect(object).to receive(:associated_objects_to_hash)
      object.as_hash
    end

    it 'calls #remove_duplicate_associated_keys' do
      test_record = create(:test_record, :with_child_records)
      versioned_hash = { "v_#{VERSION}".to_sym => [:name] }
      object = DvelpApiResponse::Base.new(test_record, VERSION, [])

      allow(object).to receive(:versioned_hash).and_return(versioned_hash)

      expect(object).to receive(:remove_duplicate_associated_keys)

      object.as_hash
    end
  end

  describe '#parse_versioned_hash' do
    context 'it does not have method #versioned_hash' do
      it 'returns nil' do
        test_record = create(:test_record, :with_child_records)
        object = DvelpApiResponse::Base.new(test_record, VERSION, [])

        allow(object).to receive(:respond_to?).with(:versioned_hash)
          .and_return(false)

        expect(object.parse_versioned_hash).to eq(nil)
      end
    end

    it 'adds the attributes to the hash' do
      test_record = create(:test_record, :with_child_records)
      versioned_hash = { "v_#{VERSION}".to_sym => [:name] }
      object = DvelpApiResponse::Base.new(test_record, VERSION, [])

      allow(object).to receive(:versioned_hash).and_return(versioned_hash)

      expect { object.parse_versioned_hash }
        .to change { object.hash }.to(name: test_record.name)
    end
  end

  describe '#associated_objects_to_hash' do
    it 'adds associated_objects to the hash variable' do
      test_record = create(:test_record, :with_child_records)
      object = DvelpApiResponse::Base.new(test_record, VERSION, [])

      associated_objects = [{ child_records: 1 }]

      allow(object).to receive(:associated_objects)
        .and_return(associated_objects)

      expect { object.associated_objects_to_hash }
        .to change { object.hash }.to(associated_objects.first)
    end
  end

  describe '#associated_objects' do
    it 'returns an array' do
      test_record = create(:test_record, :with_child_records)
      object = DvelpApiResponse::Base
        .new(test_record, VERSION, ['child_records'])

      expect(object.associated_objects).to be_a(Array)
    end

    it 'returns an array of associated api_responses' do
      test_record = create(:test_record, :with_child_records)
      object = DvelpApiResponse::Base
        .new(test_record, VERSION, ['child_records'])

      expect(object.associated_objects.flat_map(&:keys))
        .to include(:child_records)
    end
  end

  describe '#remove_duplicate_associated_keys' do
    it 'strips out any duplicate references' do
      test_record = create(:test_record)
      object = DvelpApiResponse::Base.new(test_record, VERSION, [])

      test_record_hash = { name: Faker::Company.name }
      hash = { test_record_id: 1, test_record: test_record_hash }

      allow(object).to receive(:hash).and_return(hash)

      expect(object.remove_duplicate_associated_keys)
        .to eq(test_record: test_record_hash)
    end
  end

  describe '#build_response' do
    it 'generates a hash for the nestedboject' do
      test_record = create(:test_record, :with_child_records)

      subject = DvelpApiResponse::Base.new(test_record, VERSION, ['child_records'])
      child = subject.associated_items.first
      child_name = test_record.child_records.first.name

      child_record_hash = {
        child_records: [{ id: 1, name: child_name }]
      }

      expect(subject.build_response(child))
        .to eq(child_record_hash)
    end
  end
end
