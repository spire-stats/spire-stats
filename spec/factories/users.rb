FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "test-user#{n}@example.com" }
    password { "password123" }
    password_confirmation { "password123" }
  end
end
