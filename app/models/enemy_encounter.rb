class EnemyEncounter < ApplicationRecord
  belongs_to :run

  validates :enemies, :floor, presence: true
  validates :run_id, uniqueness: { scope: :floor }

  scope :elites, -> { where(is_elite: true) }
  scope :bosses, -> { where(is_boss: true) }
  scope :regular, -> { where(is_elite: false, is_boss: false) }

  before_save :check_if_killing_blow

  def self.process_for_run(run, damage_taken_data)
    return unless damage_taken_data

    damage_taken_data.each do |encounter_data|
      is_elite = elite_encounter?(encounter_data["enemies"])
      is_boss = boss_encounter?(encounter_data["enemies"])

      run.enemy_encounters.create(
        enemies: encounter_data["enemies"],
        floor: encounter_data["floor"],
        damage_taken: encounter_data["damage"],
        turns: encounter_data["turns"],
        is_elite: is_elite,
        is_boss: is_boss,
        was_killing_blow: (run.killed_by == encounter_data["enemies"])
      )
    end
  end

  private

  def self.elite_encounter?(enemies)
    elite_patterns = [
      /Gremlin Nob/, /Lagavulin/, /Sentries/, /Book of Stabbing/,
      /Taskmaster/, /Gremlin Leader/, /Automaton/, /Nemesis/,
      /Giant Head/, /Reptomancer/
    ]

    elite_patterns.any? { |pattern| enemies.match?(pattern) }
  end

  def self.boss_encounter?(enemies)
    boss_patterns = [
      /The Guardian/, /Hexaghost/, /Slime Boss/, /Champ/,
      /Collector/, /Automaton/, /Donu and Deca/, /Awakened One/,
      /Time Eater/, /The Heart/
    ]

    boss_patterns.any? { |pattern| enemies.match?(pattern) }
  end

  def check_if_killing_blow
    self.was_killing_blow = (run.killed_by == enemies)
  end
end
