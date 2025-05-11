class CreateRelics < ActiveRecord::Migration[8.0]
  def change
    create_table :relics do |t|
      t.string :name, null: false
      t.string :rarity
      t.string :character
      t.text :description
      t.text :flavor_text

      t.timestamps
    end

    add_index :relics, :name, unique: true
  end
end
