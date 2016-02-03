class CreateScenes < ActiveRecord::Migration
  def change
    create_table :scenes do |t|
      t.string :title
      t.integer :user_id
      t.datetime :submitted_at
      t.datetime :approved_at
      t.integer :status, default: 0
      t.string :first_banner
      t.string :second_banner
      t.string :description
      t.string :web_link
      t.integer :startup_id, default: 0
      t.integer :parent_id, default: 0

      t.timestamps
    end
  end
end
