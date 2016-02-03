# == Schema Information
#
# Table name: installations
#
#  id          :integer(4)      not null, primary key
#  name        :string(255)
#  home_page   :string(255)
#  playlist_id :integer(4)
#  created_at  :datetime        not null
#  updated_at  :datetime        not null
#  time_zone   :string(255)     default("Eastern Time (US & Canada)")
#

class Installation < ActiveRecord::Base
  attr_accessible :home_page, :name, :time_zone, :playlist_id

  # any user in this collection is a site admin of this installation
  has_and_belongs_to_many :admins, class_name: 'User'

  has_many :playlists, dependent: :destroy
  belongs_to :default_playlist, class_name: 'Playlist', foreign_key: :playlist_id

  validates :name, presence: true, length: { maximum: 255 }
  validates :home_page, link_format: true
end
