# frozen_string_literal: true

describe DvelpApiResponse::AssociationFactory do
  VERSION = 1

  describe '#associated_items' do
    context 'with no child records' do
      let(:object) { create(:test_record) }

      it 'returns an empty array' do
        includes = []
        subject = described_class.new(object, includes)

        expect(subject.associated_items).to eq []
      end
    end

    context 'with a nested records' do
      let(:object) { create(:test_record, :with_child_and_toys) }

      it '' do
        associates = ['toy_records', { 'child_records' => 'toy_records' }]
        subject = described_class.new(object, associates)
        expected = [
          item_parser.new('toy_records'),
          item_parser.new({ 'child_records' => 'toy_records' })
        ]

        expect(subject.associated_items.map(&:object_name))
          .to eq expected.map(&:object_name)
        expect(subject.associated_items.map(&:nested_includes))
          .to eq expected.map(&:nested_includes)
        expect(subject.associated_items.map(&:included_item))
          .to eq expected.map(&:included_item)
      end

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

  def item_parser
    DvelpApiResponse::IncludeItemParser
  end
end
