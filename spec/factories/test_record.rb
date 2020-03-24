# frozen_string_literal: true

FactoryBot.define do
  factory :test_record, class: TestRecord do
    name { Faker::Company.name }
  end

  trait :with_child_records do
    after(:create) do |test_record|
      create(:child_record, test_record: test_record)
    end
  end
end
