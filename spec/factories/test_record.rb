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

  trait :child_with_toys do
    after(:create) do |test_record|
      create(:child_record, :with_toy_records, test_record: test_record)
    end
  end

  trait :with_child_and_toys do
    after(:create) do |test_record|
      create(:child_record, :with_toy_records, test_record: test_record)
      create(:toy_record, test_record: test_record)
    end
  end
end
