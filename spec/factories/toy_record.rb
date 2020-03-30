# frozen_string_literal: true

FactoryBot.define do
  factory :toy_record do
    test_record { nil }
    child_record { nil }
    name { Faker::Company.name }
  end
end
