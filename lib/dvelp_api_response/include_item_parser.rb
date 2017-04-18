# frozen_string_literal: true

module DvelpApiResponse
  class IncludeItemParser
    attr_reader :included_item

    def initialize(included_item)
      @included_item = included_item
    end

    def object_name
      @object_name ||=
        if included_item.is_a?(Hash)
          included_item.keys[0]
        else
          included_item
        end
    end

    def nested_includes
      included_item.is_a?(Hash) ? included_item[object_name] : []
    end
  end
end
