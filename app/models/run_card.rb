class RunCard < ApplicationRecord
  belongs_to :run
  belongs_to :card

  scope :not_removed, -> { where(removed: false) }
  scope :early_game, -> { where(floor_obtained: 0..17) }
  scope :mid_game, -> { where(floor_obtained: 18..34) }
  scope :late_game, -> { where(floor_obtained: 35..Float::INFINITY) }

  # This method finds cards in the deck at the end of the run by looking at the run's master_deck
  # card_acquisition_history is a hash mapping card names to arrays of acquisition details:
  # {
  #   "card_name" => [
  #     { floor: 3, source: "combat" },
  #     { floor: 9, source: "combat" }
  #   ]
  # }
  def self.from_master_deck(run, master_deck, card_acquisition_history = {})
    processed_card_counts = Hash.new(0)

    master_deck.map do |card_name|
      upgraded = card_name.include?("+")
      base_name = card_name.gsub(/\+\d+$/, "")

      card = Card.find_by(name: base_name)

      unless card
        card = Card.create!(
          name: base_name,
          character: run.character,
          card_type: "UNKNOWN",
          rarity: "UNKNOWN",
          cost: 0,
          description: "Description unknown"
        )
        Rails.logger.info("Created new card: #{base_name} for character: #{run.character}")
      end

      acquisition_details = card_acquisition_history[base_name]

      floor_obtained = nil
      source = nil

      if acquisition_details && acquisition_details.is_a?(Array)
        current_index = processed_card_counts[base_name]
        if current_index < acquisition_details.size
          floor_obtained = acquisition_details[current_index][:floor]
          source = acquisition_details[current_index][:source]
        end
        processed_card_counts[base_name] += 1
      elsif is_likely_starter_card?(base_name, run.character)
        floor_obtained = 0
        source = "starter"
      end

      create(
        run: run,
        card: card,
        upgraded: upgraded,
        floor_obtained: floor_obtained,
        source: source
      )
    end.compact
  end

  def self.is_likely_starter_card?(card_name, character)
    ironclad_starters = [ "Strike", "Defend", "Bash" ]
    silent_starters = [ "Strike", "Defend", "Neutralize", "Survivor" ]
    defect_starters = [ "Strike", "Defend", "Zap", "Dualcast" ]
    watcher_starters = [ "Strike", "Defend", "Eruption", "Vigilance" ]

    case character
    when "IRONCLAD"
      ironclad_starters.include?(card_name)
    when "THE_SILENT"
      silent_starters.include?(card_name)
    when "DEFECT"
      defect_starters.include?(card_name)
    when "WATCHER"
      watcher_starters.include?(card_name)
    else
      false
    end
  end
end
