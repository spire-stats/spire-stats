class AddInternalNameToRelics < ActiveRecord::Migration[8.0]
  def change
    add_column :relics, :internal_name, :string
  end
end
