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

require 'test_helper'

class PlaylistTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
