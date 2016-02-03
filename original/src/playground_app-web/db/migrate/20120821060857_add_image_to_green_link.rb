class AddImageToGreenLink < ActiveRecord::Migration
  def change
  	add_column :green_links, :image_id, :integer
  end
end
