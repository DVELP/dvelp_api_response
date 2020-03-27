# frozen_string_literal: true

module DvelpApiResponse
  class Base
    attr_reader :object, :version, :includes, :hash, :options

    def initialize(object, version, *includes, options: {})
      @object = object
      @version = version
      @includes = includes.flatten
      @hash = {}
      @options = options
    end

    def as_hash
      parse_versioned_hash
      parse_versioned_hash_extended
      associated_objects_to_hash
      remove_duplicate_associated_keys
    end

    def parse_versioned_hash
      parse_hash(:versioned_hash)
    end

    def parse_versioned_hash_extended
      return unless options[:extended]
      parse_hash(:versioned_hash_extended)
    end

    def parse_hash(hash_method)
      return unless respond_to?(hash_method)
      send(hash_method)["v_#{version}".to_sym].try(:each) do |attribute|
        attribute =
          if attribute.is_a?(Hash)
            attribute
          else
            { attribute => object.send(attribute) }
          end
        hash.merge!(attribute)
      end
    end

    def associated_objects_to_hash
      associated_objects.each do |associated_object|
        hash.merge!(associated_object)
      end
    end

    def associated_objects
      return [] if includes.empty?

      associated_items.map do |association|
        build_response(association)
      end
    end

    def build_response(association)
      DvelpApiResponse::Distributor.new(
        object_with_relations.send(association.object_name),
        version,
        association.nested_includes,
        false
      ).build_response
    end

    def remove_duplicate_associated_keys
      hash.each_key { |key| hash.delete("#{key}_id".to_sym) }
      hash
    end

    def versioned_hash
      {}
    end

    private

    delegate :associated_items,
             :object_with_relations,
             to: :association_factory

    def association_factory
      @association_factory ||=
        DvelpApiResponse::AssociationFactory.new(object, includes)
    end
  end
end
