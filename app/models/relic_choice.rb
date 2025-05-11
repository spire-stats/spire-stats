class RelicChoice < ApplicationRecord
  belongs_to :run
  belongs_to :relic

  scope :picked, -> { where(picked: true) }
  scope :not_picked, -> { where(picked: false) }

  # Method to process boss relic choices from run file
  def self.process_boss_relics(run, boss_relics)
    return [] unless boss_relics

    results = []

    boss_relics.each_with_index do |choice, index|
      # Determine floor based on which boss (Act 1, 2, or 3)
      estimated_floor = case index
      when 0 then 16  # Act 1 boss
      when 1 then 33  # Act 2 boss
      else 50         # Act 3 boss
      end

      # Process the picked relic
      if choice["picked"] != "SKIP"
        relic = Relic.find_by(name: choice["picked"])

        if relic
          results << create(
            run: run,
            relic: relic,
            floor: estimated_floor,
            picked: true,
            source: "boss"
          )
        end
      end

      # Process the not picked relics
      if choice["not_picked"].present?
        choice["not_picked"].each do |not_picked_name|
          relic = Relic.find_by(name: not_picked_name)

          if relic
            results << create(
              run: run,
              relic: relic,
              floor: estimated_floor,
              picked: false,
              source: "boss"
            )
          end
        end
      end
    end

    results
  end

  # Method to process shop relic choices from run file
  def self.process_shop_relics(run, shop_contents)
    return [] unless shop_contents

    results = []

    shop_contents.each do |shop|
      floor = shop["floor"]

      if shop["relics"].present?
        shop["relics"].each do |relic_name|
          relic = Relic.find_by(name: relic_name)

          if relic
            # Determine if it was purchased by checking items_purchased
            was_purchased = run.items_purchased.include?(relic_name)

            results << create(
              run: run,
              relic: relic,
              floor: floor,
              picked: was_purchased,
              source: "shop"
            )
          end
        end
      end
    end

    results
  end

  # Method to process event relic choices from run file
  def self.process_event_relics(run, event_choices)
    return [] unless event_choices

    results = []

    event_choices.each do |event|
      if event["relics_obtained"].present?
        floor = event["floor"]

        event["relics_obtained"].each do |relic_name|
          relic = Relic.find_by(name: relic_name)

          if relic
            results << create(
              run: run,
              relic: relic,
              floor: floor,
              picked: true,
              source: "event"
            )
          end
        end
      end
    end

    results
  end
end
