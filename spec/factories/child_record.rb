# frozen_string_literal: true

FactoryBot.define do
  factory :child_record, class: ChildRecord do
    test_record
    name { Faker::Company.name }
  end

  trait :with_toy_records do
    after(:create) do |child_record|
      create(:toy_record, child_record: child_record)
    end
  end
end
