module SpireStats
  class DeckTracker
    attr_reader :acquisition_history

    def collect_card_events
      _collect_card_events
    end

    def initialize(run, run_file_reader)
      @run = run
      @run_file_reader = run_file_reader
      @acquisition_history = {}
      @card_instances = {}

      initialize_starter_deck
      process_all_card_events
      finalize_acquisition_history
    end

    def card_acquisition_history
      finalize_acquisition_history
      @acquisition_history
    end

    def finalize_acquisition_history
      @acquisition_history = {}

      @card_instances.each do |card_name, instances|
        @acquisition_history[card_name] = instances.map { |instance| instance.except(:id) }
      end
    end

    private

    def initialize_starter_deck
      starter_cards = identify_starter_cards(@run.character)

      starter_cards.each_with_index do |card_name, index|
        @card_instances[card_name] ||= []
        @card_instances[card_name] << {
          id: "#{card_name}_starter_#{index}",
          floor: 0,
          source: "starter"
        }
      end
    end

    def process_all_card_events
      all_card_events = _collect_card_events
      all_card_events.sort_by! { |event| event[:floor] }

      removed_cards = {}

      all_card_events.each do |event|
        card_name = event[:card]
        base_name = card_name.gsub(/\+\d+$/, "")

        if event[:action] == :add
          @card_instances[base_name] ||= []
          card_id = "#{base_name}_#{event[:source]}_#{event[:floor]}_#{@card_instances[base_name].length}"

          @card_instances[base_name] << {
            id: card_id,
            floor: event[:floor],
            source: event[:source]
          }

        elsif event[:action] == :remove
          removed_cards[base_name] ||= 0
          removed_cards[base_name] += 1
        end
      end

      removed_cards.each do |card_name, count|
        if @card_instances[card_name] && count > 0
          @card_instances[card_name] = @card_instances[card_name].drop([ count, @card_instances[card_name].length ].min)
        end
      end
    end

    def _collect_card_events
      card_events = []

      @run_file_reader.card_choices.each do |choice|
        next unless choice["picked"] && choice["picked"] != "SKIP"

        card_events << {
          card: choice["picked"],
          floor: choice["floor"],
          source: "combat",
          action: :add
        }
      end

      @run_file_reader.items_purchased.each do |purchase|
        next unless purchase["purchased"] == "CARD"

        card_events << {
          card: purchase["item_id"],
          floor: purchase["floor"],
          source: "shop",
          action: :add
        }
      end

      @run_file_reader.event_choices.each do |event|
        next unless event["cards_obtained"] && !event["cards_obtained"].empty?

        event["cards_obtained"].each do |card|
          card_events << {
            card: card,
            floor: event["floor"],
            source: "event",
            action: :add
          }
        end
      end

      @run_file_reader.cards_removed.each do |card|
        floor = 0

        @run_file_reader.event_choices.each do |event|
          if event["cards_removed"] && event["cards_removed"].include?(card)
            floor = event["floor"]
            break
          end
        end

        card_events << {
          card: card,
          floor: floor,
          action: :remove
        }
      end

      card_events
    end

    def identify_starter_cards(character)
      case character
      when "IRONCLAD"
        [ "Strike" ] * 5 + [ "Defend" ] * 4 + [ "Bash" ]
      when "THE_SILENT"
        [ "Strike" ] * 5 + [ "Defend" ] * 5 + [ "Neutralize", "Survivor" ]
      when "DEFECT"
        [ "Strike" ] * 4 + [ "Defend" ] * 4 + [ "Zap", "Dualcast" ]
      when "WATCHER"
        [ "Strike" ] * 4 + [ "Defend" ] * 4 + [ "Eruption", "Vigilance" ]
      else
        []
      end
    end
  end
end
