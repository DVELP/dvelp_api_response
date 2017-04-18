# frozen_string_literal: true

module DvelpApiResponse
  class Pagination
    attr_reader :object

    def initialize(object)
      @object = object

      unless object.respond_to?(:total_pages)
        raise I18n.t('render_errors.paginated')
      end
    end

    def as_hash
      { pagination: attributes }
    end

    def attributes
      global_attributes.merge!(prev_page) if object.try(:prev_page)
      global_attributes.merge!(next_page) if object.try(:next_page)
      global_attributes
    end

    def global_attributes
      @attributes ||=
        {
          current_page: object.current_page,
          total_pages: object.total_pages,
          total_count: object.total_count
        }
    end

    def prev_page
      {
        prev_page: object.prev_page
      }
    end

    def next_page
      {
        next_page: object.next_page
      }
    end
  end
end
