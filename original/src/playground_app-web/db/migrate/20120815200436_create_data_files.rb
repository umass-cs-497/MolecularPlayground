class CreateDataFiles < ActiveRecord::Migration
  def change
    create_table :data_files do |t|
      t.string :filename
      t.binary :data, limit: 50.megabyte
      t.integer :scene_id
      t.integer :content_type, default: 0

      t.timestamps
    end
  end
end
