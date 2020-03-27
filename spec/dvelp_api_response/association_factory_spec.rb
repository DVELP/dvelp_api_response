# frozen_string_literal: true

describe DvelpApiResponse::AssociationFactory do

  # add model and factory for another type
  # add a nested type so can test:
  #   TestRecord has_many :child_records
  #   ChildRecord has_many :toy_records
  #   TestRecord has_many :toy_records

  describe '#associated_items' do
    context 'with child records' do

    end

    context 'with no child records' do

    end

    context 'with nested toy_records includes' do

    end
  end

  describe '#object_with_relations' do
    # check that the test record is returned fully populated
    # and the DB is only called once (ie/ not called when relations are accessed)
  end

  describe '#associations' do
    it 'returns each included item' do
      # check against a nest and multiple items
    end
  end

  describe '#parse_item' do
    it 'instantiates an IncludedItemParser' do
      # just check call to .new
    end
  end

  describe '#valid_associations' do
    it "memoizes the object class's related models" do
      # check the @valid_associations instance variable
    end
  end

  describe '#valid_association?(associated_object)' do
    context 'relation exists between objects' do
      it 'returns true' do
        test_record = create(:test_record, :with_child_records)
        object = DvelpApiResponse::AssociationFactory
                   .new(test_record, ['child_records'])

        expect(
          object.send(:valid_association?, 'child_records')
        ).to eq(true)
      end
    end

    context 'relation does not exist between objects' do
      it 'returns false' do
        test_record = create(:test_record)
        object = DvelpApiResponse::AssociationFactory
                   .new(test_record, [])

        expect(
          object.send(:valid_association?, 'invalid_association')
        ).to eq(false)
      end
    end
  end
end
