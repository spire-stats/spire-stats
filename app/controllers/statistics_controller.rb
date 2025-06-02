class StatisticsController < ApplicationController
  def index
    @total_runs = Run.count
    @victory_rate = (Run.victories.count.to_f / @total_runs * 100).round(2) if @total_runs > 0

    @character_stats = character_stats
    @most_picked_cards = most_picked_cards
    @most_skipped_cards = most_skipped_cards
    @most_acquired_relics = most_acquired_relics
    @most_rejected_relics = most_rejected_relics
  end

  def cards
    @character = params[:character]
    @cards = Card.by_character(@character).order(:name)
    @card_stats = card_stats(@character)
  end

  def card
    @card = Card.find(params[:id])
    @pick_rate = calculate_pick_rate(@card)
    @win_rate_with_card = calculate_win_rate_with_card(@card)
    @average_floor_taken = CardChoice.where(card: @card, picked: true).average(:floor)&.round(1)
    @runs_with_card = RunCard.where(card: @card).count
  end

  def relics
    @character = params[:character]
    @relics = Relic.where(character: [ nil, @character ]).order(:name)
    @relic_stats = relic_stats(@character)
  end

  def relic
    @relic = Relic.find(params[:id])
    @acquisition_rate = calculate_acquisition_rate(@relic)
    @win_rate_with_relic = calculate_win_rate_with_relic(@relic)
    @runs_with_relic = RunRelic.where(relic: @relic).count
  end

  def encounters
    @enemy_encounters = EnemyEncounter.group(:enemies)
      .select("enemies, COUNT(*) as count, AVG(damage_taken) as avg_damage, AVG(turns) as avg_turns,
               SUM(CASE WHEN was_killing_blow THEN 1 ELSE 0 END) as killing_blows")
      .order("count DESC")
      .limit(20)
  end

  private

  def character_stats
    Run.group(:character)
      .select("character, COUNT(*) as total,
               SUM(CASE WHEN victory THEN 1 ELSE 0 END) as victories,
               AVG(floor_reached) as avg_floor")
      .map do |stat|
        {
          character: stat.character,
          name: Run::CHARACTER_NAME_MAPPING[stat.character],
          total: stat.total,
          victories: stat.victories,
          win_rate: (stat.victories.to_f / stat.total * 100).round(2),
          avg_floor: stat.avg_floor.round(1)
        }
      end
  end

  def most_picked_cards(limit = 10)
    CardChoice.where(picked: true)
      .joins(:card)
      .group("cards.id, cards.name, cards.character, cards.card_type")
      .select("cards.id, cards.name, cards.character, cards.card_type, COUNT(*) as pick_count")
      .order("pick_count DESC")
      .limit(limit)
  end

  def most_skipped_cards(limit = 10)
    CardChoice.where(picked: false)
      .joins(:card)
      .group("cards.id, cards.name, cards.character, cards.card_type")
      .select("cards.id, cards.name, cards.character, cards.card_type, COUNT(*) as skip_count")
      .order("skip_count DESC")
      .limit(limit)
  end

  def most_acquired_relics(limit = 10)
    RunRelic.joins(:relic)
      .group("relics.id, relics.name, relics.rarity")
      .select("relics.id, relics.name, relics.rarity, COUNT(*) as acquire_count")
      .order("acquire_count DESC")
      .limit(limit)
  end

  def most_rejected_relics(limit = 10)
    RelicChoice.where(picked: false)
      .joins(:relic)
      .group("relics.id, relics.name, relics.rarity")
      .select("relics.id, relics.name, relics.rarity, COUNT(*) as reject_count")
      .order("reject_count DESC")
      .limit(limit)
  end

  def card_stats(character)
    Card.where(character: character)
      .joins("LEFT JOIN card_choices ON cards.id = card_choices.card_id")
      .group("cards.id, cards.name")
      .select("cards.id, cards.name,
               SUM(CASE WHEN card_choices.picked THEN 1 ELSE 0 END) as times_picked,
               SUM(CASE WHEN card_choices.picked = false THEN 1 ELSE 0 END) as times_skipped")
      .map do |stat|
        total = stat.times_picked + stat.times_skipped
        pick_rate = total > 0 ? (stat.times_picked.to_f / total * 100).round(2) : 0

        {
          id: stat.id,
          name: stat.name,
          times_picked: stat.times_picked,
          times_skipped: stat.times_skipped,
          pick_rate: pick_rate
        }
      end
  end

  def relic_stats(character)
    Relic.where(character: [ nil, character ])
      .joins("LEFT JOIN relic_choices ON relics.id = relic_choices.relic_id")
      .group("relics.id, relics.name")
      .select("relics.id, relics.name,
               SUM(CASE WHEN relic_choices.picked THEN 1 ELSE 0 END) as times_acquired,
               SUM(CASE WHEN relic_choices.picked = false THEN 1 ELSE 0 END) as times_rejected")
      .map do |stat|
        total = stat.times_acquired + stat.times_rejected
        acquisition_rate = total > 0 ? (stat.times_acquired.to_f / total * 100).round(2) : 0

        {
          id: stat.id,
          name: stat.name,
          times_acquired: stat.times_acquired,
          times_rejected: stat.times_rejected,
          acquisition_rate: acquisition_rate
        }
      end
  end

  def calculate_pick_rate(card)
    total_offered = CardChoice.where(card: card).count
    total_picked = CardChoice.where(card: card, picked: true).count

    total_offered > 0 ? (total_picked.to_f / total_offered * 100).round(2) : 0
  end

  def calculate_win_rate_with_card(card)
    runs_with_card = Run.joins(:run_cards).where(run_cards: { card_id: card.id }).distinct
    total_runs = runs_with_card.count
    victories = runs_with_card.where(victory: true).count

    total_runs > 0 ? (victories.to_f / total_runs * 100).round(2) : 0
  end

  def calculate_acquisition_rate(relic)
    total_offered = RelicChoice.where(relic: relic).count
    total_acquired = RelicChoice.where(relic: relic, picked: true).count

    total_offered > 0 ? (total_acquired.to_f / total_offered * 100).round(2) : 0
  end

  def calculate_win_rate_with_relic(relic)
    runs_with_relic = Run.joins(:run_relics).where(run_relics: { relic_id: relic.id }).distinct
    total_runs = runs_with_relic.count
    victories = runs_with_relic.where(victory: true).count

    total_runs > 0 ? (victories.to_f / total_runs * 100).round(2) : 0
  end
end
