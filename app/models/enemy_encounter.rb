class EnemyEncounter < ApplicationRecord
  belongs_to :run

  validates :enemies, :floor, presence: true
  validates :run_id, uniqueness: { scope: :floor }

  scope :elites, -> { where(is_elite: true) }
  scope :bosses, -> { where(is_boss: true) }
  scope :regular, -> { where(is_elite: false, is_boss: false) }

  # Helper to determine if this was the encounter that killed the player
  before_save :check_if_killing_blow

  private

  def check_if_killing_blow
    self.was_killing_blow = (run.killed_by == enemies)
  end

  # Helper class method to identify elite encounters
  def self.elite_encounter?(enemies)
    elite_patterns = [
      /Gremlin Nob/, /Lagavulin/, /Sentries/, /Book of Stabbing/,
      /Taskmaster/, /Gremlin Leader/, /Automaton/, /Nemesis/,
      /Giant Head/, /Reptomancer/
    ]

    elite_patterns.any? { |pattern| enemies.match?(pattern) }
  end

  # Helper class method to identify boss encounters
  def self.boss_encounter?(enemies)
    boss_patterns = [
      /The Guardian/, /Hexaghost/, /Slime Boss/, /Champ/,
      /Collector/, /Automaton/, /Donu and Deca/, /Awakened One/,
      /Time Eater/, /The Heart/
    ]

    boss_patterns.any? { |pattern| enemies.match?(pattern) }
  end
end
