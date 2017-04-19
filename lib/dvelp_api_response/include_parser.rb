# frozen_string_literal: true

module DvelpApiResponse
  class IncludeParser
    attr_reader :includes

    def initialize(*includes)
      @includes = includes.flatten.compact
    end

    def parsed_array
      ([compacted_hashes] + base_level_includes).flatten
    end

    private

    def compacted_hashes
      nested_includes.group_by(&:keys).flat_map do |k, v|
        { k.first => v.flat_map(&:values) }
      end
    end

    def base_level_includes
      formatted_array.reject { |a| a.is_a?(Hash) }
    end

    def nested_includes
      formatted_array.select { |a| a.is_a?(Hash) }
    end

    def formatted_array
      @formatted_array ||= includes.map { |string| format_string(string) }
    end

    def format_string(include_string)
      array = include_string.split('.')
      parent = array.shift
      children = array.join('.')
      !children.empty? ? { parent => format_string(children) } : parent
    end
  end
end
