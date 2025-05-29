FactoryBot.define do
  factory :run do
    character { "IRONCLAD" }
    ascension_level { 20 }
    floor_reached { 50 }
    victory { true }
    seed { "ABCDEF" }
    run_at { Time.current }

    # Required associations
    association :user
    association :run_file
  end
end
