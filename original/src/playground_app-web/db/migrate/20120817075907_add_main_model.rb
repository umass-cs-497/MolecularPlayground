class AddMainModel < ActiveRecord::Migration
  def change
  	add_column :scenes, :model_id, :integer
  end

end
