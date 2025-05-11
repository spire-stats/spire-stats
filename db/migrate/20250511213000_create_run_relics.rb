class CreateRunRelics < ActiveRecord::Migration[8.0]
  def change
    create_table :run_relics do |t|
      t.references :run, null: false, foreign_key: true, index: true
      t.references :relic, null: false, foreign_key: true, index: true
      t.integer :floor_obtained

      t.timestamps
    end

    add_index :run_relics, [ :run_id, :relic_id ], unique: true
  end
end
