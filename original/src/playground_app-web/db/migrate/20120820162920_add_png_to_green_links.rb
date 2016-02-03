class AddPngToGreenLinks < ActiveRecord::Migration
  def change
  	add_column :green_links, :png_url, :string 
  end
end
