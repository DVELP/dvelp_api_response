# frozen_string_literal: true

class TestRecordResponder < DvelpApiResponse::Base
  def versioned_hash
    {
      v_1: %i[id name]
    }
  end
end
