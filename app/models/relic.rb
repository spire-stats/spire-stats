class Relic < ApplicationRecord
  has_many :run_relics
  has_many :runs, through: :run_relics
  has_many :relic_choices

  validates :name, presence: true, uniqueness: true

  scope :by_character, ->(char) { where(character: char) }
  scope :by_rarity, ->(rarity) { where(rarity: rarity) }
end
