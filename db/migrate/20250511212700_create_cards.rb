class CreateCards < ActiveRecord::Migration[8.0]
  def change
    create_table :cards do |t|
      t.string :name, null: false
      t.string :card_type
      t.string :rarity
      t.integer :cost
      t.string :character
      t.text :description
      t.boolean :base_version, default: true

      t.timestamps
    end

    add_index :cards, :name, unique: true
  end
end
