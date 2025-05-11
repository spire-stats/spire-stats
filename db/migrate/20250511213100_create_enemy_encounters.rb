class CreateEnemyEncounters < ActiveRecord::Migration[8.0]
  def change
    create_table :enemy_encounters do |t|
      t.references :run, null: false, foreign_key: true, index: true
      t.string :enemies, null: false
      t.integer :floor, null: false
      t.integer :damage_taken
      t.integer :turns
      t.boolean :is_elite, default: false
      t.boolean :is_boss, default: false
      t.boolean :was_killing_blow, default: false

      t.timestamps
    end

    add_index :enemy_encounters, [ :run_id, :floor ], unique: true
    add_index :enemy_encounters, :enemies
  end
end
