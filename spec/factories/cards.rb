FactoryBot.define do
  factory :card do
    name { "Strike" }
    character { "IRONCLAD" }
    card_type { "ATTACK" }
    rarity { "BASIC" }
    cost { 1 }
    description { "Deal 6 damage." }
  end
end
