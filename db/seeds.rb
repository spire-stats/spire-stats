# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
require_relative '../lib/run_file_reader'

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

Dir[File.join('db/data/runs', '*.run')].each do |file|
  run_json = File.read(file)
  run_file = RunFile.find_or_create_by(
    run_data: run_json,
    user: data_user
  )

  reader = SpireStats::RunFileReader.new(run_json)
  Run.find_or_create_by(
    character: reader.character,
    ascension_level: reader.ascension_level,
    floor_reached: reader.floor_reached,
    seed: reader.seed,
    victory: reader.victory,
    killed_by: reader.killed_by,
    card_picks: reader.card_picks,
    run_at: reader.run_at,
    user: data_user,
    run_file: run_file
  )
end

puts "Database seeded successfully!"
