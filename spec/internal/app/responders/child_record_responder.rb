# frozen_string_literal: true

class ChildRecordResponder < DvelpApiResponse::Base
  def versioned_hash
    {
      v_1: %i[id name]
    }
  end
end
