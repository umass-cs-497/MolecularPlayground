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

require 'test_helper'

class PlaylistItemTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
