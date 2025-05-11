class UpdateCardNameUniquenessIndex < ActiveRecord::Migration[8.0]
  def change
    # Remove the old index that just uses name
    remove_index :cards, :name

    # Add a new composite index on name and character
    add_index :cards, [ :name, :character ], unique: true
  end
end
