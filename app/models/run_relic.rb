class RunRelic < ApplicationRecord
  belongs_to :run
  belongs_to :relic

  validates :run_id, uniqueness: { scope: :relic_id }

  scope :early_game, -> { where(floor_obtained: 0..17) }
  scope :mid_game, -> { where(floor_obtained: 18..34) }
  scope :late_game, -> { where(floor_obtained: 35..Float::INFINITY) }

  def self.from_run_data(run, relics, relics_obtained)
    relics.map do |relic_name|
      relic = Relic.find_by(name: relic_name)

      relic_obtained = relics_obtained.find { |r| r["key"] == relic_name }
      floor = relic_obtained ? relic_obtained["floor"] : nil

      create(
        run: run,
        relic: relic,
        floor_obtained: floor
      )
    end.compact
  end
end
