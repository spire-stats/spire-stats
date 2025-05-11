class CardChoice < ApplicationRecord
  belongs_to :run
  belongs_to :card

  validates :floor, presence: true

  scope :picked, -> { where(picked: true) }
  scope :not_picked, -> { where(picked: false) }
  scope :early_game, -> { where(floor: 0..17) }
  scope :mid_game, -> { where(floor: 18..34) }
  scope :late_game, -> { where(floor: 35..Float::INFINITY) }

  # Method to process card choices from run file
  def self.process_from_run_data(run, card_choices)
    return [] unless card_choices

    results = []

    card_choices.each do |choice|
      floor = choice["floor"]
      context = choice["context"] # might be nil

      # Process the picked card
      if choice["picked"] != "SKIP"
        base_name = choice["picked"].gsub(/\+\d+$/, "")
        card = Card.find_by(name: base_name)

        if card
          results << create(
            run: run,
            card: card,
            floor: floor,
            picked: true,
            context: context
          )
        end
      end

      # Process the not picked cards
      if choice["not_picked"].present?
        choice["not_picked"].each do |not_picked_name|
          base_name = not_picked_name.gsub(/\+\d+$/, "")
          card = Card.find_by(name: base_name)

          if card
            results << create(
              run: run,
              card: card,
              floor: floor,
              picked: false,
              context: context
            )
          end
        end
      end
    end

    results
  end
end
