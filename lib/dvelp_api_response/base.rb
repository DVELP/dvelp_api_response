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
      includes.map do |included_association|
        include_parser = DvelpApiResponse::IncludeItemParser
          .new(included_association)
        associated_object = include_parser.object_name

        next unless valid_association?(associated_object)

        nested_includes = include_parser.nested_includes

        DvelpApiResponse::Distributor.new(
          object.send(associated_object),
          version,
          nested_includes,
          false
        ).build_response
      end.compact
    end

    def valid_association?(associated_object)
      object.respond_to?(associated_object) &&
        object.send(associated_object).present?
    end

    def remove_duplicate_associated_keys
      hash.each_key { |key| hash.delete("#{key}_id".to_sym) }
      hash
    end

    def versioned_hash
      {}
    end
  end
end
