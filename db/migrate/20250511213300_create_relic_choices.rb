class CreateRelicChoices < ActiveRecord::Migration[8.0]
  def change
    create_table :relic_choices do |t|
      t.references :run, null: false, foreign_key: true, index: true
      t.references :relic, null: false, foreign_key: true, index: true
      t.integer :floor
      t.boolean :picked, null: false, default: false
      t.string :source, default: "boss"

      t.timestamps
    end

    add_index :relic_choices, [ :run_id, :relic_id, :source ], name: 'idx_relic_choices_unique'
  end
end
