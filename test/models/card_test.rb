require "test_helper"

class CardTest < ActiveSupport::TestCase
  test "should allow duplicate card names across different characters" do
    # Strike appears for every character
    Card.create(
      name: "Strike",
      card_type: "Attack",
      rarity: "Basic",
      cost: 1,
      character: "IRONCLAD"
    )

    card = Card.new(
      name: "Strike",
      card_type: "Attack",
      rarity: "Basic",
      cost: 1,
      character: "THE_SILENT"
    )

    assert card.save, "Could not save duplicate card name for different character"
  end

  test "should not allow duplicate card names for the same character" do
    Card.create(
      name: "Test Card",
      card_type: "Attack",
      rarity: "Common",
      cost: 1,
      character: "IRONCLAD"
    )

    card = Card.new(
      name: "Test Card",
      card_type: "Attack",
      rarity: "Uncommon",
      cost: 2,
      character: "IRONCLAD"
    )

    assert_not card.save, "Saved duplicate card name for the same character"
  end

  test "should find all versions of a card" do
    Card.create(
      name: "Anger",
      card_type: "Attack",
      rarity: "Common",
      cost: 0,
      character: "IRONCLAD",
      base_version: true
    )

    Card.create(
      name: "Anger+",
      card_type: "Attack",
      rarity: "Common",
      cost: 0,
      character: "IRONCLAD",
      base_version: false
    )

    versions = Card.find_all_versions("Anger")
    assert_equal 2, versions.size, "Did not find all versions of the card"
  end
end
