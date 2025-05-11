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
  end
end
