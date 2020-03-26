# frozen_string_literal: true

module DvelpApiResponse
  class IncludeParser
    attr_reader :includes

    def initialize(*includes)
      @includes = includes.flatten.compact
      partition_relations
    end

    def parsed_array
      ([indirect_relations] + direct_relations).flatten
    end

    private

    attr_reader :direct_relations, :nested_relations

    def indirect_relations
      nested_relations.group_by(&:keys).flat_map do |k, v|
        { k.first => v.flat_map(&:values) }
      end
    end

    def partition_relations
      @nested_relations, @direct_relations =
        relations.partition { |relationship| relationship.is_a?(Hash) }
    end

    def relations
      includes.map { |include_string| resolve_relations(include_string) }
    end

    def resolve_relations(include_string)
      return include_string unless include_string.include?('.')

      array = include_string.split('.').reverse
      last_relation = array.shift

      array.each do |relation|
        last_relation = { relation => last_relation.clone }
      end
      last_relation
    end
  end
end
