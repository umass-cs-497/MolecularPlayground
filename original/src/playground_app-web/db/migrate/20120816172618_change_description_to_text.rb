class ChangeDescriptionToText < ActiveRecord::Migration
  def up
  	change_column :scenes, :description, :text
  end

  def down
  	change_column :scenes, :description, :string
  end
end
