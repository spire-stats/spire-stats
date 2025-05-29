class RelicChoice < ApplicationRecord
  belongs_to :run
  belongs_to :relic

  # Constants for relic sources/rarities
  BOSS  = "BOSS"
  SHOP  = "SHOP"
  EVENT = "EVENT"

  scope :picked, -> { where(picked: true) }
  scope :not_picked, -> { where(picked: false) }

  def self.find_or_create_relic(relic_name, run, source)
    relic = Relic.find_by(name: relic_name)

    unless relic
      character = RunRelic.determine_relic_character(relic_name, run.character)
      rarity = source.upcase

      relic = Relic.create!(
        name: relic_name,
        character: character,
        rarity: rarity,
        description: "Description unknown",
        flavor_text: "Flavor text unknown"
      )

      Rails.logger.info("Created new #{source} relic: #{relic_name} for character: #{character || 'All'}")
    end

    relic
  end

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

      if choice["picked"] != "SKIP"
        relic = find_or_create_relic(choice["picked"], run, BOSS)

        results << create(
          run: run,
          relic: relic,
          floor: estimated_floor,
          picked: true,
          source: BOSS
        )
      end

      # Process the not picked relics
      if choice["not_picked"].present?
        choice["not_picked"].each do |not_picked_name|
          relic = find_or_create_relic(not_picked_name, run, BOSS)

          results << create(
            run: run,
            relic: relic,
            floor: estimated_floor,
            picked: false,
            source: BOSS
          )
        end
      end
    end

    results
  end

  def self.process_shop_relics(run, run_file_reader)
    shop_contents = run_file_reader.shop_contents
    return [] unless shop_contents

    results = []
    items_purchased_list = run_file_reader.items_purchased

    shop_contents.each do |shop|
      floor = shop["floor"]

      if shop["relics"].present?
        shop["relics"].each do |relic_name|
          relic = find_or_create_relic(relic_name, run, SHOP)

          was_purchased = items_purchased_list.include?(relic_name)

          results << create(
            run: run,
            relic: relic,
            floor: floor,
            picked: was_purchased,
            source: SHOP
          )
        end
      end
    end

    results
  end

  def self.process_event_relics(run, event_choices)
    return [] unless event_choices

    results = []

    event_choices.each do |event|
      if event["relics_obtained"].present?
        floor = event["floor"]

        event["relics_obtained"].each do |relic_name|
          relic = find_or_create_relic(relic_name, run, EVENT)

          results << create(
            run: run,
            relic: relic,
            floor: floor,
            picked: true,
            source: EVENT
          )
        end
      end
    end

    results
  end
end
