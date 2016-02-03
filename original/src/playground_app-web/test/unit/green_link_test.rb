# == Schema Information
#
# Table name: green_links
#
#  id         :integer(4)      not null, primary key
#  title      :string(255)
#  model_id   :integer(4)
#  script_id  :integer(4)
#  scene_id   :integer(4)
#  active     :boolean(1)
#  position   :integer(4)
#  created_at :datetime        not null
#  updated_at :datetime        not null
#  image_id   :integer(4)
#

require 'test_helper'

class GreenLinkTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
