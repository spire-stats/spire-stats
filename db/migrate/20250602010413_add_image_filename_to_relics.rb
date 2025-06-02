class AddImageFilenameToRelics < ActiveRecord::Migration[8.0]
  def change
    add_column :relics, :image_filename, :string
  end
end
