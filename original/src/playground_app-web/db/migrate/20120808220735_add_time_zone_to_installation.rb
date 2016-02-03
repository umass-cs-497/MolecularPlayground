class AddTimeZoneToInstallation < ActiveRecord::Migration
  def change
  	add_column :installations, :time_zone, :string, default: 'Eastern Time (US & Canada)'
  end
end
