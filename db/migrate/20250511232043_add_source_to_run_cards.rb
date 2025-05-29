class AddSourceToRunCards < ActiveRecord::Migration[8.0]
  def change
    add_column :run_cards, :source, :string
  end
end
