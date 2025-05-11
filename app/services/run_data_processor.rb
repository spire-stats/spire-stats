module RunDataProcessor
  # Process a run file and extract all relevant data
  def self.process_run_file(run_file)
    return if run_file.run_data.blank?

    ActiveRecord::Base.transaction do
      # Parse the run data
      run_file_reader = SpireStats::RunFileReader.new(run_file.run_data)

      # Create a new run record
      run = create_run(run_file, run_file_reader)

      # Process cards, relics, and encounters
      process_cards(run, run_file_reader)
      process_relics(run, run_file_reader)
      process_encounters(run, run_file_reader)
      process_choices(run, run_file_reader)

      run
    end
  rescue StandardError => e
    # Log the error but don't prevent file upload
    Rails.logger.error("Error processing run data: #{e.message}\n#{e.backtrace.join("\n")}")
    nil
  end

  private

  def self.create_run(run_file, run_file_reader)
    Run.create!(
      run_file: run_file,
      user: run_file.user,
      character: run_file_reader.character,
      ascension_level: run_file_reader.ascension_level,
      floor_reached: run_file_reader.floor_reached,
      victory: run_file_reader.victory,
      killed_by: run_file_reader.killed_by,
      seed: run_file_reader.seed,
      created_at: run_file_reader.run_at || Time.current
    )
  end

  def self.process_cards(run, run_file_reader)
    # Process cards in the master deck
    RunCard.from_master_deck(run, run_file_reader.master_deck)
  end

  def self.process_relics(run, run_file_reader)
    # Process relics obtained during the run
    RunRelic.from_run_data(run, run_file_reader.relics, run_file_reader.relics_obtained)
  end

  def self.process_encounters(run, run_file_reader)
    # Process damage taken from enemies (enemy encounters)
    run.process_damage_taken(run_file_reader.damage_taken)
  end

  def self.process_choices(run, run_file_reader)
    # Process card and relic choices
    run.process_choice_data(run_file_reader)
  end
end
