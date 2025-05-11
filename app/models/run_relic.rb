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

      unless relic
        # Create the relic with default values
        # We can improve this later with actual data if needed
        # Determine if this is a character-specific relic based on the run character
        character = determine_relic_character(relic_name, run.character)

        relic = Relic.create!(
          name: relic_name,
          character: character,
          rarity: "UNKNOWN",  # Default rarity
          description: "Description unknown", # Default description
          flavor_text: "Flavor text unknown"  # Default flavor text
        )
        Rails.logger.info("Created new relic: #{relic_name} for character: #{character || 'All'}")
      end

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

  # Helper method to determine if a relic is likely character-specific
  # This can be improved later with better heuristics
  def self.determine_relic_character(relic_name, run_character)
    # Some common patterns for character-specific relics
    ironclad_patterns = [
      "Blood", "Burning", "Rupture", "Brutality", "Juggernaut", "Champion", "Brimstone",
      "Charon", "Black Blood", "Red Skull"
    ]

    silent_patterns = [
      "Poison", "Shuriken", "Kunai", "Ninja", "Ring of the Snake", "Ring of the Serpent",
      "After Image", "Tough Bandages", "The Specimen"
    ]

    defect_patterns = [
      "Capacit", "Orb", "Core", "Inserter", "Nuclear", "Gold-Plated",
      "Runic Capacitor", "Cracked Core", "Frozen Core", "Emotion Chip"
    ]

    watcher_patterns = [
      "Mantra", "Deva", "Blasphemy", "Violet", "Collect", "Deus Ex Machina",
      "Holy Water", "Pure Water", "Teardrop Locket"
    ]

    # Check if the relic name matches any character-specific patterns
    if ironclad_patterns.any? { |pattern| relic_name.include?(pattern) }
      "IRONCLAD"
    elsif silent_patterns.any? { |pattern| relic_name.include?(pattern) }
      "THE_SILENT"
    elsif defect_patterns.any? { |pattern| relic_name.include?(pattern) }
      "DEFECT"
    elsif watcher_patterns.any? { |pattern| relic_name.include?(pattern) }
      "WATCHER"
    else
      # If no clear pattern match, assume it might be character-specific to the current run's character
      # We can refine this logic later
      nil # Null means available to all characters
    end
  end
end
