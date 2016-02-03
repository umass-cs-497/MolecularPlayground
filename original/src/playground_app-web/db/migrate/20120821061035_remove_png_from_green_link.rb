class RemovePngFromGreenLink < ActiveRecord::Migration
  def change
  	remove_column :green_links, :png_url
  end
end
