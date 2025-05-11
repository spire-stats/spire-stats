class RunCard < ApplicationRecord
  belongs_to :run
  belongs_to :card

  scope :not_removed, -> { where(removed: false) }
  scope :early_game, -> { where(floor_obtained: 0..17) }
  scope :mid_game, -> { where(floor_obtained: 18..34) }
  scope :late_game, -> { where(floor_obtained: 35..Float::INFINITY) }

  # This method finds cards in the deck at the end of the run
  # by looking at the run's master_deck
  def self.from_master_deck(run, master_deck)
    master_deck.map do |card_name|
      # Extract base name and upgraded status
      upgraded = card_name.include?("+")
      base_name = card_name.gsub(/\+\d+$/, "")

      # Find the card in the database
      card = Card.find_by(name: base_name)

      # Skip if we don't have this card in our database yet
      next unless card

      # Create the run_card record
      create(
        run: run,
        card: card,
        upgraded: upgraded,
        # We don't know the floor_obtained from master_deck
        floor_obtained: nil
      )
    end.compact
  end
end
