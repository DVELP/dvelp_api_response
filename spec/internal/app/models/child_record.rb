# frozen_string_literal: true

class ChildRecord < ActiveRecord::Base
  belongs_to :test_record
end
