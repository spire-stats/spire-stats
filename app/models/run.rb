class Run < ApplicationRecord
  belongs_to :user
  belongs_to :run_file

  CHARACTER_NAME_MAPPING = {
    "IRONCLAD" => "Ironclad",
    "THE_SILENT" => "Silent",
    "DEFECT" => "Defect",
    "WATCHER" => "Watcher"
  }

  scope :by_character, ->(char) { where(character: char) }

  def character_name
    CHARACTER_NAME_MAPPING[character]
  end

  def victory?
    victory
  end
end
