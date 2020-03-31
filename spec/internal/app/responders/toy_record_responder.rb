# freeze_string_literal: true

class ToyRecordResponder < DvelpApiResponse::Base
  def versioned_hash
    {
      v_1: %i[id name]
    }
  end
end
