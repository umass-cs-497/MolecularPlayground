class CreateGreenLinks < ActiveRecord::Migration
  def change
    create_table :green_links do |t|
      t.string :title
      t.integer :model_id
      t.integer :script_id
      t.integer :scene_id
      t.boolean :active
      t.integer :position

      t.timestamps
    end
  end
end
