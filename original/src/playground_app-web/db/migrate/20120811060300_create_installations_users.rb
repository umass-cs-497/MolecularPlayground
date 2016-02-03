class CreateInstallationsUsers < ActiveRecord::Migration
  def change
  	create_table :installations_users, id: false do |t|
  		t.integer :installation_id
  		t.integer :user_id
  	end
  end
end
