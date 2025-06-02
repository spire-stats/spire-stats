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

  def process_choice_data(run_file_reader)
    CardChoice.process_from_run_data(self, run_file_reader.card_choices)
    RelicChoice.process_all_from_run_data(self, run_file_reader)
  end
end
