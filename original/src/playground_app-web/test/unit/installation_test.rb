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
#  time_zone   :string(255)
#

require 'test_helper'

class InstallationTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
