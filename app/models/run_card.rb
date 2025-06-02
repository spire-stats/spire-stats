class RunCard < ApplicationRecord
  belongs_to :run
  belongs_to :card

  scope :not_removed, -> { where(removed: false) }
  scope :early_game, -> { where(floor_obtained: 0..17) }
  scope :mid_game, -> { where(floor_obtained: 18..34) }
  scope :late_game, -> { where(floor_obtained: 35..Float::INFINITY) }

  def self.from_master_deck(run, master_deck, card_acquisition_history = {})
    processed_card_counts = Hash.new(0)

    master_deck.map do |card_name|
      upgraded = card_name.include?("+")
      base_name = card_name.gsub(/\+\d+$/, "")

      card = Card.find_by(name: base_name)

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
      elsif is_starter_card?(base_name)
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

  def self.is_starter_card?(card_name)
    [ "Strike", "Defend", "Bash", "Neutralize", "Survivor", "Zap", "Dualcast", "Eruption", "Vigilance" ].include?(card_name)
  end
end
