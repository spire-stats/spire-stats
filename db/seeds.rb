# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
require_relative '../lib/run_file_reader'
require_relative '../app/services/run_data_processor'

puts "Seeding database..."

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
