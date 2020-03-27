module DvelpApiResponse
  class AssociationFactory
    def initialize(object, includes = [])
      @object = object
      @includes = includes
    end

    def associated_items
      @associated_items ||= includes.map do |association|
        item = parse_item(association)
        next unless valid_association?(item.object_name)
        item
      end.compact
    end

    def object_with_relations
      @object_with_relations ||=
        object.class
          .includes(*associations)
          .find(object.id)
    end

    private

    attr_reader :object, :includes

    def associations
      associated_items.map(&:included_item)
    end

    def parse_item(association)
      DvelpApiResponse::IncludeItemParser.new(association)
    end

    def valid_association?(associated_object)
      valid_associations.include?(associated_object)
    end

    def valid_associations
      @valid_associations ||= object.class.reflections.keys
    end
  end
end
