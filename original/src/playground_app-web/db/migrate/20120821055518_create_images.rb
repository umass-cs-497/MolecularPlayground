class CreateImages < ActiveRecord::Migration
  def change
    create_table :images do |t|
      t.binary :data, limit: 5.megabyte
      t.timestamps
    end
  end
end
