class CreateInstallations < ActiveRecord::Migration
  def change
    create_table :installations do |t|
      t.string :name
      t.string :home_page
      t.integer :playlist_id

      t.timestamps
    end
  end
end
