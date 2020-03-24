# frozen_string_literal: true

FactoryBot.define do
  factory :child_record, class: ChildRecord do
    test_record
    name { Faker::Company.name }
  end
end
