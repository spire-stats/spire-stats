module SpireStats
  class RunFileReader
    def initialize(run_json)
      @run_data = JSON.parse(run_json)
    end

    def ascension_level
      @run_data["ascension_level"]
    end

    def character
      @run_data["character_chosen"]
    end

    def seed
      @run_data["seed_played"]
    end

    def floor_reached
      @run_data["floor_reached"]
    end

    def victory
      @run_data["victory"]
    end

    def killed_by
      @run_data["killed_by"]
    end

    def run_at
      ts = @run_data["timestamp"]
      return nil unless ts
        Time.at(ts).in_time_zone
    end

    def master_deck
      @run_data["master_deck"] || []
    end

    def card_choices
      @run_data["card_choices"] || []
    end

    def relics
      @run_data["relics"] || []
    end

    def relics_obtained
      @run_data["relics_obtained"] || []
    end

    def damage_taken
      @run_data["damage_taken"] || []
    end

    def boss_relics_data
      @run_data["boss_relics"] || []
    end

    def shop_contents
      @run_data["shop_contents"] || []
    end

    def event_choices
      @run_data["event_choices"] || []
    end

    def items_purchased
      @run_data["items_purchased"] || []
    end

    def cards_removed
      result = []

      # Check events that removed cards
      if @run_data["event_choices"].present?
        @run_data["event_choices"].each do |event|
          if event["cards_removed"].present?
            result.concat(event["cards_removed"])
          end
        end
      end

      # Add purged cards
      if @run_data["items_purged"].present?
        result.concat(@run_data["items_purged"])
      end

      result
    end
  end
end
