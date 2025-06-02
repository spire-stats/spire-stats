require 'json'

require_relative '../lib/run_file_reader'
require_relative '../app/services/run_data_processor'

puts "Seeding database..."
puts "Seeding cards and relics from db/data/items.json..."

json_file_path = Rails.root.join('db', 'data', 'items.json')

unless File.exist?(json_file_path)
  puts "ERROR: items.json not found at #{json_file_path}"
else
  file_content = File.read(json_file_path)
  data_hash = JSON.parse(file_content)

  puts "Seeding cards..."
  cards_created = 0
  data_hash["cards"]&.each do |card_data|
    character = CHARACTER_MAP[card_data["color"]]
    unless character
      puts "  Skipping card #{card_data['name']} due to unknown color: #{card_data['color']}"
      next
    end

    card_cost =
      if card_data["cost"] == "X"
        -1
      elsif card_data["cost"].present?
        card_data["cost"].to_i
      else
        nil
      end

    base_version = !card_data["name"].end_with?('+')

    Card.find_or_create_by!(
      name: card_data["name"],
      character: character
    ) do |card|
      card.card_type = card_data["type"]
      card.rarity = card_data["rarity"]
      card.cost = card_cost
      card.description = card_data["description"]
      card.base_version = base_version

      cleaned_card_name = card_data["name"].gsub(/\s+/, '').gsub(/[^a-zA-Z0-9]/, '')
      card.image_filename = base_version ? "#{cleaned_card_name}.png" : "#{cleaned_card_name}Plus.png"
      cards_created += 1 if card.new_record?
    end
  end
  puts "  Created: #{cards_created}."

  puts "Seeding relics..."
  relics_created = 0
  data_hash["relics"]&.each do |relic_data|
    character = CHARACTER_MAP[relic_data["pool"]]
    character ||= "NEUTRAL"

    Relic.find_or_create_by!(
      name: relic_data["name"]
    ) do |relic|
      relic.rarity = relic_data["tier"]
      relic.character = character
      relic.description = relic_data["description"]
      relic.flavor_text = relic_data["flavorText"]

      cleaned_relic_name = relic_data["name"].gsub(/\s+/, '').gsub(/[^a-zA-Z0-9]/, '')
      relic.image_filename = "#{cleaned_relic_name}.png"
      relics_created += 1 if relic.new_record?
    end
  end
  puts "  Created: #{relics_created}."

  puts "Finished seeding cards and relics."
end

data_user = User.find_by(email: 'data@spirestats.com')
if data_user.nil?
  puts "Admin user not found, creating..."
  data_user = User.new(
    email: 'data@spirestats.com',
    password: 'password',
    password_confirmation: 'password',
    admin: true
  )
  data_user.skip_confirmation!
  data_user.save!
end

puts "Seeding run files from db/data/runs..."

Dir[File.join('db/data/runs', '*.run')].each do |file|
  puts "Processing #{File.basename(file)}..."
  run_json = File.read(file)

  run_file = RunFile.find_or_create_by(
    run_data: run_json,
    user: data_user
  )

  if run_file.run.present?
    puts "  Run already exists for #{File.basename(file)}, skipping"
    next
  end

  begin
    puts "  Processing data..."
    run = SpireStats::RunDataProcessor.new.process_run_file(run_file)

    if run
      puts "  Successfully processed run for #{run.character_name} (Ascension #{run.ascension_level})"
      puts "  Created #{run.run_cards.count} cards, #{run.run_relics.count} relics"
    else
      puts "  Error processing run data"
    end
  rescue => e
    puts "  Error processing #{File.basename(file)}: #{e.message}"
  end
end

puts "Database seeded successfully!"
