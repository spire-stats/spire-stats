class AddImageFilenameToCards < ActiveRecord::Migration[8.0]
  def change
    add_column :cards, :image_filename, :string
  end
end
