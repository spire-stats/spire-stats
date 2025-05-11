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

    # Returns an array of hashes with :card_name, :floor, and :act keys for every card that was picked during the run.
    # The underlying run file contains a `card_choices` array where each element looks like:
    #   { "picked" => "Anger", "not_picked" => ["Body Slam", "Rampage"], "floor" => 3 }
    # We take the `picked` value and record the floor it was obtained on.
    def card_picks
      return [] unless @run_data["card_choices"].is_a?(Array)

      @run_data["card_choices"].filter_map do |choice|
        picked = choice["picked"]
        floor  = choice["floor"]
        next unless picked && floor

        { card_name: picked, floor: floor, act: act_for_floor(floor) }
      end
    end

    private

    def act_for_floor(floor)
      case floor
      when 1..16 then 1
      when 17..33 then 2
      when 34..51 then 3
      else 4
      end
    end
  end
end
