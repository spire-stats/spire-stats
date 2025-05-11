class CreateRunCards < ActiveRecord::Migration[8.0]
  def change
    create_table :run_cards do |t|
      t.references :run, null: false, foreign_key: true, index: true
      t.references :card, null: false, foreign_key: true, index: true
      t.integer :floor_obtained
      t.boolean :upgraded, default: false
      t.boolean :removed, default: false

      t.timestamps
    end

    add_index :run_cards, [ :run_id, :card_id, :floor_obtained ], name: 'idx_run_cards_occurrence'
  end
end
