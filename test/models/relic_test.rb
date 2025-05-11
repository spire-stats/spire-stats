require "test_helper"

class RelicTest < ActiveSupport::TestCase
  test "should not save relic without name" do
    relic = Relic.new(
      rarity: "Common",
      description: "Test description",
      flavor_text: "Test flavor text"
    )
    assert_not relic.save, "Saved the relic without a name"
  end

  test "should not allow duplicate relic names" do
    # Create a relic
    Relic.create(
      name: "Test Relic",
      rarity: "Common",
      description: "Test description",
      flavor_text: "Test flavor text"
    )

    # Try to create a duplicate
    relic2 = Relic.new(
      name: "Test Relic",
      rarity: "Uncommon",
      description: "Different description",
      flavor_text: "Different flavor text"
    )

    assert_not relic2.save, "Saved duplicate relic name"
  end

  test "should associate relics with runs" do
    # Create a user
    user = User.create(email: "test@example.com", password: "password")

    # Create a run file
    run_file = RunFile.create(
      user: user,
      run_data: "{}"
    )

    # Create a run
    run = Run.create(
      user: user,
      run_file: run_file,
      character: "IRONCLAD",
      ascension_level: 1,
      victory: true
    )

    # Create a relic
    relic = Relic.create(
      name: "Test Relic",
      rarity: "Common",
      description: "Test description"
    )

    # Associate relic with run
    RunRelic.create(
      run: run,
      relic: relic,
      floor_obtained: 10
    )

    # Test the association
    assert_equal 1, run.relics.count
    assert_equal "Test Relic", run.relics.first.name
    assert_equal 1, relic.runs.count
  end
end
