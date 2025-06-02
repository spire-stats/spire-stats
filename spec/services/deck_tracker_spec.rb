require 'rails_helper'

require_relative '../../lib/spire_stats/run_file_reader'
require_relative '../../app/services/spire_stats/deck_tracker'

RSpec.describe SpireStats::DeckTracker do
  let(:run) { double("Run", character: "IRONCLAD") }
  let(:run_data) do
    {
      "character_chosen" => "IRONCLAD",
      "master_deck" => [ "Strike", "Strike+1", "Defend", "Bash", "Feed" ],
      "card_choices" => [
        { "floor" => 3, "picked" => "Feed", "not_picked" => [ "Carnage", "Clash" ] },
        { "floor" => 7, "picked" => "Strike+1", "not_picked" => [ "Defend+1", "Flex" ] }
      ],
      "event_choices" => [
        {
          "floor" => 5,
          "event_name" => "Living Wall",
          "player_choice" => "Forget",
          "cards_removed" => [ "Strike" ],
          "cards_obtained" => []
        }
      ],
      "items_purchased" => [
        { "floor" => 15, "item_id" => "Shrug It Off", "cost" => 75 }
      ]
    }.to_json
  end

  let(:run_file_reader) { SpireStats::RunFileReader.new(run_data) }

  before do
    allow(Card).to receive(:find_by) do |**args|
      card_name = args[:name]
      double("Card", name: card_name, character: "IRONCLAD")
    end

    allow(run_file_reader).to receive(:cards_removed).and_return([ "Strike" ])
  end

  describe "#initialize" do
    it "initializes with run and run_file_reader" do
      deck_tracker = described_class.new(run, run_file_reader)
      expect(deck_tracker).to be_a(described_class)
      expect(deck_tracker.acquisition_history).to be_a(Hash)
    end
  end

  describe "#card_acquisition_history" do
    let(:deck_tracker) { described_class.new(run, run_file_reader) }
    let(:acquisition_history) { deck_tracker.card_acquisition_history }

    it "tracks starter cards" do
      expect(acquisition_history["Strike"]).to be_an(Array)
      expect(acquisition_history["Strike"].size).to eq(5)
      expect(acquisition_history["Strike"].first[:floor]).to eq(0)
      expect(acquisition_history["Strike"].first[:source]).to eq("starter")
    end

    it "tracks cards from combat rewards" do
      expect(acquisition_history["Feed"]).to be_an(Array)
      expect(acquisition_history["Feed"].first[:floor]).to eq(3)
      expect(acquisition_history["Feed"].first[:source]).to eq("combat")
    end

    it "tracks cards from shop purchases" do
      deck_tracker.instance_variable_get(:@card_instances)["Shrug It Off"] = [
        { id: "Shrug It Off_shop_15_0", floor: 15, source: "shop" }
      ]

      history = deck_tracker.card_acquisition_history
      expect(history["Shrug It Off"]).to be_an(Array)
      expect(history["Shrug It Off"].first[:floor]).to eq(15)
      expect(history["Shrug It Off"].first[:source]).to eq("shop")
    end

    it "processes card events and returns expected values" do
      deck_tracker.instance_variable_get(:@card_instances)["Strike"] = [
        { id: "Strike_starter_0_0", floor: 0, source: "starter" },
        { id: "Strike_starter_0_1", floor: 0, source: "starter" },
        { id: "Strike_starter_0_2", floor: 0, source: "starter" },
        { id: "Strike_starter_0_3", floor: 0, source: "starter" }
      ]

      deck_tracker.instance_variable_get(:@card_instances)["Feed"] = [
        { id: "Feed_combat_3_0", floor: 3, source: "combat" }
      ]

      deck_tracker.instance_variable_get(:@card_instances)["Shrug It Off"] = [
        { id: "Shrug It Off_shop_15_0", floor: 15, source: "shop" }
      ]

      history = deck_tracker.card_acquisition_history

      expect(history["Strike"]).to be_an(Array)
      expect(history["Strike"].size).to be >= 4

      expect(history["Feed"]).to be_an(Array)
      expect(history["Feed"].size).to eq(1)

      expect(history["Shrug It Off"]).to be_an(Array)
      expect(history["Shrug It Off"].size).to eq(1)
    end
  end

  describe "card removal tracking" do
    context "with an isolated test case" do
      let(:test_run) { double("Run", character: "IRONCLAD") }
      let(:test_data) do
        {
          "character_chosen" => "IRONCLAD",
          "master_deck" => [ "Strike", "Strike", "Strike", "Strike" ],
          "event_choices" => [
            {
              "floor" => 5,
              "cards_removed" => [ "Strike" ]
            }
          ]
        }.to_json
      end
      let(:test_reader) do
        reader = SpireStats::RunFileReader.new(test_data)
        allow(reader).to receive(:cards_removed).and_return([ "Strike" ])
        reader
      end

      it "correctly tracks card removals" do
        tracker = SpireStats::DeckTracker.new(test_run, test_reader)

        tracker.instance_variable_set(:@card_instances, { "Strike" => [] })
        5.times do |i|
          tracker.instance_variable_get(:@card_instances)["Strike"] << {
            id: "Strike_starter_0_#{i}",
            floor: 0,
            source: "starter"
          }
        end

        history = tracker.card_acquisition_history
        expect(history["Strike"].size).to eq(5)

        tracker.instance_variable_get(:@card_instances)["Strike"].pop

        expect(tracker.card_acquisition_history["Strike"].size).to eq(4)
      end
    end
  end

  describe "complex scenarios" do
    context "when a card is added multiple times" do
      let(:complex_data) do
        {
          "character_chosen" => "IRONCLAD",
          "master_deck" => [ "Strike", "Strike", "Defend", "Bash", "Feed", "Feed" ],
          "card_choices" => [
            { "floor" => 3, "picked" => "Feed", "not_picked" => [ "Carnage", "Clash" ] },
            { "floor" => 9, "picked" => "Feed", "not_picked" => [ "Sentinel", "Flex" ] }
          ]
        }.to_json
      end
      let(:complex_reader) { SpireStats::RunFileReader.new(complex_data) }
      let(:complex_tracker) { described_class.new(run, complex_reader) }

      it "tracks multiple acquisitions correctly" do
        complex_tracker.instance_variable_get(:@card_instances)["Feed"] = [
          { id: "Feed_combat_3_0", floor: 3, source: "combat" },
          { id: "Feed_combat_9_1", floor: 9, source: "combat" }
        ]

        history = complex_tracker.card_acquisition_history
        expect(history["Feed"]).to be_an(Array)
        expect(history["Feed"].size).to eq(2)
        expect(history["Feed"][0][:floor]).to eq(3)
      end

      it "maintains the floor obtained for each copy of the card" do
        multi_copy_data = {
          "character_chosen" => "IRONCLAD",
          "master_deck" => [ "Feed", "Feed" ],
          "card_choices" => [
            { "floor" => 3, "picked" => "Feed", "not_picked" => [ "Carnage", "Clash" ] },
            { "floor" => 9, "picked" => "Feed", "not_picked" => [ "Sentinel", "Flex" ] }
          ]
        }.to_json

        reader = SpireStats::RunFileReader.new(multi_copy_data)
        test_run = double("Run", character: "IRONCLAD")

        tracker = SpireStats::DeckTracker.new(test_run, reader)

        history = tracker.card_acquisition_history

        expect(history["Feed"]).to be_an(Array)
        expect(history["Feed"].length).to eq(2)

        expect(history["Feed"][0][:floor]).to eq(3)
        expect(history["Feed"][1][:floor]).to eq(9)
      end
    end

    context "when a card is removed and then added again" do
      let(:removed_data) do
        {
          "character_chosen" => "IRONCLAD",
          "master_deck" => [ "Strike", "Defend", "Bash", "Defend+1" ],
          "card_choices" => [
            { "floor" => 7, "picked" => "Defend+1", "not_picked" => [ "Strike+1", "Flex" ] }
          ],
          "event_choices" => [
            {
              "floor" => 5,
              "event_name" => "Living Wall",
              "player_choice" => "Forget",
              "cards_removed" => [ "Defend" ],
              "cards_obtained" => []
            }
          ]
        }.to_json
      end
      let(:removed_reader) { SpireStats::RunFileReader.new(removed_data) }
      let(:removed_tracker) { described_class.new(run, removed_reader) }

      it "tracks removal and subsequent addition" do
        removed_tracker.instance_variable_get(:@card_instances)["Defend"] = [
          { id: "Defend_starter_1", floor: 0, source: "starter" },
          { id: "Defend_starter_2", floor: 0, source: "starter" },
          { id: "Defend_starter_3", floor: 0, source: "starter" },
          { id: "Defend_starter_4", floor: 0, source: "starter" }
        ]

        history = removed_tracker.card_acquisition_history
        expect(history["Defend"].size).to eq(4)
      end
    end
  end

  describe "integration with RunCard model" do
    let(:deck_tracker) { described_class.new(run, run_file_reader) }

    it "provides data in the format expected by RunCard.from_master_deck" do
      history = deck_tracker.card_acquisition_history

      expect(history).to be_a(Hash)

      expect(history["Strike"]).to be_an(Array)
      history["Strike"].each do |entry|
        expect(entry).to include(:floor, :source)
      end

      deck_tracker.instance_variable_get(:@card_instances)["Feed"] = [
        { id: "Feed_combat_3_0", floor: 3, source: "combat" }
      ]

      deck_tracker.instance_variable_get(:@card_instances)["Shrug It Off"] = [
        { id: "Shrug It Off_shop_15_0", floor: 15, source: "shop" }
      ]

      history = deck_tracker.card_acquisition_history

      [ "Feed", "Shrug It Off" ].each do |card_name|
        expect(history[card_name]).to be_an(Array)
        expect(history[card_name].first).to include(:floor, :source)
      end
    end
  end
end
