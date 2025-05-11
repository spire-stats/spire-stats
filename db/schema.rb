# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_05_11_221500) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pg_stat_statements"

  create_table "card_choices", force: :cascade do |t|
    t.bigint "run_id", null: false
    t.bigint "card_id", null: false
    t.integer "floor", null: false
    t.boolean "picked", default: false, null: false
    t.string "context"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["card_id"], name: "index_card_choices_on_card_id"
    t.index ["run_id", "floor", "card_id"], name: "idx_card_choices_unique"
    t.index ["run_id"], name: "index_card_choices_on_run_id"
  end

  create_table "cards", force: :cascade do |t|
    t.string "name", null: false
    t.string "card_type"
    t.string "rarity"
    t.integer "cost"
    t.string "character"
    t.text "description"
    t.boolean "base_version", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name", "character"], name: "index_cards_on_name_and_character", unique: true
  end

  create_table "enemy_encounters", force: :cascade do |t|
    t.bigint "run_id", null: false
    t.string "enemies", null: false
    t.integer "floor", null: false
    t.integer "damage_taken"
    t.integer "turns"
    t.boolean "is_elite", default: false
    t.boolean "is_boss", default: false
    t.boolean "was_killing_blow", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["enemies"], name: "index_enemy_encounters_on_enemies"
    t.index ["run_id", "floor"], name: "index_enemy_encounters_on_run_id_and_floor", unique: true
    t.index ["run_id"], name: "index_enemy_encounters_on_run_id"
  end

  create_table "relic_choices", force: :cascade do |t|
    t.bigint "run_id", null: false
    t.bigint "relic_id", null: false
    t.integer "floor"
    t.boolean "picked", default: false, null: false
    t.string "source", default: "boss"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["relic_id"], name: "index_relic_choices_on_relic_id"
    t.index ["run_id", "relic_id", "source"], name: "idx_relic_choices_unique"
    t.index ["run_id"], name: "index_relic_choices_on_run_id"
  end

  create_table "relics", force: :cascade do |t|
    t.string "name", null: false
    t.string "rarity"
    t.string "character"
    t.text "description"
    t.text "flavor_text"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_relics_on_name", unique: true
  end

  create_table "run_cards", force: :cascade do |t|
    t.bigint "run_id", null: false
    t.bigint "card_id", null: false
    t.integer "floor_obtained"
    t.boolean "upgraded", default: false
    t.boolean "removed", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["card_id"], name: "index_run_cards_on_card_id"
    t.index ["run_id", "card_id", "floor_obtained"], name: "idx_run_cards_occurrence"
    t.index ["run_id"], name: "index_run_cards_on_run_id"
  end

  create_table "run_files", force: :cascade do |t|
    t.integer "user_id"
    t.jsonb "run_data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "run_relics", force: :cascade do |t|
    t.bigint "run_id", null: false
    t.bigint "relic_id", null: false
    t.integer "floor_obtained"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["relic_id"], name: "index_run_relics_on_relic_id"
    t.index ["run_id", "relic_id"], name: "index_run_relics_on_run_id_and_relic_id", unique: true
    t.index ["run_id"], name: "index_run_relics_on_run_id"
  end

  create_table "runs", force: :cascade do |t|
    t.boolean "victory"
    t.integer "floor_reached"
    t.string "killed_by"
    t.integer "ascension_level"
    t.string "character"
    t.datetime "run_at"
    t.string "seed"
    t.bigint "user_id", null: false
    t.bigint "run_file_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["run_file_id"], name: "index_runs_on_run_file_id"
    t.index ["user_id"], name: "index_runs_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "admin", default: false, null: false
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
  end

  add_foreign_key "card_choices", "cards"
  add_foreign_key "card_choices", "runs"
  add_foreign_key "enemy_encounters", "runs"
  add_foreign_key "relic_choices", "relics"
  add_foreign_key "relic_choices", "runs"
  add_foreign_key "run_cards", "cards"
  add_foreign_key "run_cards", "runs"
  add_foreign_key "run_relics", "relics"
  add_foreign_key "run_relics", "runs"
  add_foreign_key "runs", "run_files"
  add_foreign_key "runs", "users"
end
