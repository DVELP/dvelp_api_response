# frozen_string_literal: true

FactoryGirl.define do
  factory :child_record, class: ChildRecord do
    test_record
    name Faker::Company.name
  end
end
