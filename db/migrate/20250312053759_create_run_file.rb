class CreateRunFile < ActiveRecord::Migration[8.0]
  def change
    create_table :run_files do |t|
      t.integer :user_id
      t.jsonb :run_data

      t.timestamps
    end
  end
end
