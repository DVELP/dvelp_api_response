# frozen_string_literal: true

class TestRecord < ActiveRecord::Base
  has_many :child_records
  has_many :toy_records

  validates :name, presence: true
end
