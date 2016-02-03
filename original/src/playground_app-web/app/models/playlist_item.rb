# == Schema Information
#
# Table name: playlist_items
#
#  id          :integer(4)      not null, primary key
#  playlist_id :integer(4)
#  scene_id    :integer(4)
#  position    :integer(4)
#  created_at  :datetime        not null
#  updated_at  :datetime        not null
#

class PlaylistItem < ActiveRecord::Base
  attr_accessible :playlist_id, :position, :scene_id
  belongs_to :playlist
  belongs_to :scene

  def title
  	scene.title
  end

  def author
  	scene.author.display_name
  end
  
end
