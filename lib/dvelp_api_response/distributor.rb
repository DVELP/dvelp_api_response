# frozen_string_literal: true

module DvelpApiResponse
  class Distributor
    attr_reader :resource, :version, :includes, :root, :options

    def initialize(
      resource, version, includes = nil, root = true, options: {}
    )
      @resource = resource
      @version = version
      @includes = includes
      @root = root
      @options = options
    end

    def build_response
      return nil unless resource_is_valid?
      hash = {}.merge(Hash[resource_class_as_sym, response_hash])
      hash.merge!(pagination) if paginated?
      hash
    end

    def resource_is_valid?
      resource_class != 'NilClass'
    end

    def api_response_class
      "#{resource_class}Responder".constantize
    end

    def resource_class
      @resource_class ||=
        case resource
        when ActiveRecord::Relation
          resource.model.name
        when Array
          resource.first.class.name
        else
          resource.class.name
        end
    end

    def resource_class_as_sym
      klass = resource_class.underscore.downcase
      klass = klass.pluralize if collection?
      klass.to_sym
    end

    def response_hash
      collection? ? collection_response : singular_response
    end

    def collection?
      resource.is_a?(ActiveRecord::Relation) || resource.is_a?(Array)
    end

    def collection_response
      resource.map do |object|
        api_response_class.new(
          object, version, parsed_includes, options: options
        ).as_hash
      end
    end

    def singular_response
      api_response_class.new(
        resource, version, parsed_includes, options: options
      ).as_hash
    end

    def paginated?
      collection? &&
        resource.respond_to?(:total_pages) &&
        resource.total_pages.positive?
    end

    def pagination
      DvelpApiResponse::Pagination.new(resource).as_hash
    end

    def parsed_includes
      return includes unless root
      DvelpApiResponse::IncludeParser.new(includes).parsed_array
    end
  end
end
