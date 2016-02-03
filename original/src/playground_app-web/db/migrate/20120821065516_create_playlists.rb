class CreatePlaylists < ActiveRecord::Migration
  def change
    create_table :playlists do |t|
      t.string :name
      t.integer :installation_id
      t.boolean :enabled
      t.datetime :start_at
      t.datetime :end_at

      t.timestamps
    end
  end
end
