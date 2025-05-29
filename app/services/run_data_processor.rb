module SpireStats
  class RunDataProcessor
    def process_run_file(run_file)
      return if run_file.run_data.blank?
      @run_file_reader = RunFileReader.new(run_file.run_data)

      ActiveRecord::Base.transaction do
        @run = create_run(run_file)

        process_cards
        process_relics
        process_encounters
        process_choices

        @run
      end
    rescue StandardError => e
      Rails.logger.error("Error processing run data: #{e.message}\n#{e.backtrace.join("\n")}")
      nil
    end

    private

    def create_run(run_file)
      Run.create!(
        run_file: run_file,
        user: run_file.user,
        character: @run_file_reader.character,
        ascension_level: @run_file_reader.ascension_level,
        floor_reached: @run_file_reader.floor_reached,
        victory: @run_file_reader.victory,
        killed_by: @run_file_reader.killed_by,
        seed: @run_file_reader.seed,
        run_at: @run_file_reader.run_at
      )
    end

    def process_cards
      deck_tracker = DeckTracker.new(@run, @run_file_reader)
      RunCard.from_master_deck(@run, @run_file_reader.master_deck, deck_tracker.card_acquisition_history)
    end

    def process_relics
      RunRelic.from_run_data(@run, @run_file_reader.relics, @run_file_reader.relics_obtained)
    end

    def process_encounters
      @run.process_damage_taken(@run_file_reader.damage_taken)
    end

    def process_choices
      @run.process_choice_data(@run_file_reader)
    end
  end
end
