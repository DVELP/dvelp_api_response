class ToyRecord < ActiveRecord::Base
  belongs_to :test_record
  belongs_to :child_record
end
