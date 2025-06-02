class Card < ApplicationRecord
  has_many :run_cards
  has_many :runs, through: :run_cards
  has_many :card_choices

  validates :name, presence: true
  validates :name, uniqueness: { scope: :character }

  scope :by_character, ->(char) { where(character: char) }
  scope :by_type, ->(type) { where(card_type: type) }
  scope :by_rarity, ->(rarity) { where(rarity: rarity) }
  scope :base_cards, -> { where(base_version: true) }

  def self.find_all_versions(name)
    base_name = name.gsub(/\+\d+$/, "")
    where("name LIKE ?", "#{base_name}%")
  end

  def name
    read_attribute(:name).gsub(/([a-z])([A-Z])/, '\1 \2')
  end
end
