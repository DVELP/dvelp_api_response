# frozen_string_literal: true

class ResourceTypeConflict < StandardError; end
class UnsupportedMediaType < StandardError; end
class UnacceptableMediaType < StandardError; end
class Unauthorized < StandardError; end

# Base class for all API errors
class APIError < StandardError; end
class UpdatesProhibited < APIError; end

# Base Payment API error
class PaymentAPIError < APIError; end
