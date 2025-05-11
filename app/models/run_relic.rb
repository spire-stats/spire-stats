class RunRelic < ApplicationRecord
  belongs_to :run
  belongs_to :relic

  validates :run_id, uniqueness: { scope: :relic_id }

  scope :early_game, -> { where(floor_obtained: 0..17) }
  scope :mid_game, -> { where(floor_obtained: 18..34) }
  scope :late_game, -> { where(floor_obtained: 35..Float::INFINITY) }

  # This method creates run_relic records from the relics and relics_obtained arrays
  def self.from_run_data(run, relics, relics_obtained)
    relics.map do |relic_name|
      # Find the relic in the database
      relic = Relic.find_by(name: relic_name)

      # Skip if we don't have this relic in our database yet
      next unless relic

      # Try to find the floor_obtained
      relic_obtained = relics_obtained.find { |r| r["key"] == relic_name }
      floor = relic_obtained ? relic_obtained["floor"] : nil

      # Create the run_relic record
      create(
        run: run,
        relic: relic,
        floor_obtained: floor
      )
    end.compact
  end
end
