FactoryBot.define do
  factory :run_file do
    run_data do
      {
        "character_chosen" => "IRONCLAD",
        "ascension_level" => 20,
        "seed_played" => "ABCDEF",
        "floor_reached" => 50,
        "victory" => true,
        "timestamp" => Time.current.to_i,
        "master_deck" => ["Strike", "Strike+1", "Defend", "Bash", "Feed"],
        "card_choices" => [
          {
            "floor" => 3,
            "picked" => "Feed",
            "not_picked" => ["Carnage", "Clash"],
            "picking_player" => 0
          },
          {
            "floor" => 7,
            "picked" => "Strike+1",
            "not_picked" => ["Defend+1", "Flex"],
            "picking_player" => 0
          }
        ],
        "event_choices" => [
          {
            "floor" => 5,
            "event_name" => "Living Wall",
            "player_choice" => "Forget",
            "cards_removed" => ["Strike"],
            "damage_healed" => 0,
            "gold_gain" => 0,
            "cards_obtained" => [],
            "relics_obtained" => []
          }
        ],
        "items_purchased" => [
          {
            "floor" => 15,
            "item_id" => "Shrug It Off",
            "cost" => 75
          }
        ],
        "relics" => ["Burning Blood", "Vajra"],
        "relics_obtained" => [
          {
            "floor" => 0,
            "key" => "Burning Blood"
          },
          {
            "floor" => 10,
            "key" => "Vajra"
          }
        ]
      }.to_json
    end
  end
end
