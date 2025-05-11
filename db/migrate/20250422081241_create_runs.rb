class CreateRuns < ActiveRecord::Migration[8.0]
  def change
    create_table :runs do |t|
      t.boolean :victory
      t.integer :floor_reached
      t.string :killed_by
      t.integer :ascension_level
      t.string :character
      t.datetime :run_at
      t.string :seed
      t.jsonb :card_picks, default: []

      t.references :user, null: false, foreign_key: true
      t.references :run_file, null: false, foreign_key: true

      t.timestamps
    end
  end
end
