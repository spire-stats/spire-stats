class Run < ApplicationRecord
  belongs_to :user
  belongs_to :run_file

  has_many :run_cards, dependent: :destroy
  has_many :cards, through: :run_cards

  has_many :run_relics, dependent: :destroy
  has_many :relics, through: :run_relics

  has_many :enemy_encounters, dependent: :destroy
  has_many :card_choices, dependent: :destroy
  has_many :relic_choices, dependent: :destroy

  CHARACTER_NAME_MAPPING = {
    "IRONCLAD" => "Ironclad",
    "THE_SILENT" => "Silent",
    "DEFECT" => "Defect",
    "WATCHER" => "Watcher"
  }

  scope :by_character, ->(char) { where(character: char) }
  scope :victories, -> { where(victory: true) }
  scope :defeats, -> { where(victory: false) }
  scope :by_ascension, ->(level) { where(ascension_level: level) }
  scope :by_ascension_range, ->(min, max) { where(ascension_level: min..max) }

  def character_name
    CHARACTER_NAME_MAPPING[character]
  end

  def victory?
    victory
  end

  # Helper method to process damage taken (enemy encounters)
  def process_damage_taken(damage_taken)
    return unless damage_taken

    damage_taken.each do |encounter|
      is_elite = EnemyEncounter.elite_encounter?(encounter["enemies"])
      is_boss = EnemyEncounter.boss_encounter?(encounter["enemies"])

      enemy_encounters.create(
        enemies: encounter["enemies"],
        floor: encounter["floor"],
        damage_taken: encounter["damage"],
        turns: encounter["turns"],
        is_elite: is_elite,
        is_boss: is_boss,
        was_killing_blow: (killed_by == encounter["enemies"])
      )
    end
  end

  # Process all choice data from a run file
  def process_choice_data(run_file_reader)
    # Process card choices
    CardChoice.process_from_run_data(self, run_file_reader.card_choices)

    # Process boss relic choices
    RelicChoice.process_boss_relics(self, run_file_reader.boss_relics_data)

    # Process shop relic choices
    RelicChoice.process_shop_relics(self, run_file_reader.shop_contents)

    # Process event relic choices
    RelicChoice.process_event_relics(self, run_file_reader.event_choices)
  end
end
