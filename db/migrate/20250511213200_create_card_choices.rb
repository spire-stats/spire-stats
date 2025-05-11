class CreateCardChoices < ActiveRecord::Migration[8.0]
  def change
    create_table :card_choices do |t|
      t.references :run, null: false, foreign_key: true, index: true
      t.references :card, null: false, foreign_key: true, index: true
      t.integer :floor, null: false
      t.boolean :picked, null: false, default: false
      t.string :context

      t.timestamps
    end

    add_index :card_choices, [ :run_id, :floor, :card_id ], name: 'idx_card_choices_unique'
  end
end
