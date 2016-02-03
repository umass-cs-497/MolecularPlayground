# == Schema Information
#
# Table name: playlists
#
#  id              :integer(4)      not null, primary key
#  name            :string(255)
#  installation_id :integer(4)
#  enabled         :boolean(1)
#  start_at        :datetime
#  end_at          :datetime
#  created_at      :datetime        not null
#  updated_at      :datetime        not null
#

class Playlist < ActiveRecord::Base
  attr_accessible :enabled, :end_at, :installation_id, :name, :start_at

  belongs_to :installation
  has_many :playlist_items, dependent: :destroy, order: 'position'
  has_many :scenes, through: :playlist_items

  validates :name, presence: true, length: { maximum: 200 }

  def default?
  	self.installation.default_playlist == self
  end

end
