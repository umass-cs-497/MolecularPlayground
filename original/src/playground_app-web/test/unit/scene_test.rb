# == Schema Information
#
# Table name: scenes
#
#  id            :integer(4)      not null, primary key
#  title         :string(255)
#  user_id       :integer(4)
#  submitted_at  :datetime
#  approved_at   :datetime
#  status        :integer(4)      default(0)
#  first_banner  :string(255)
#  second_banner :string(255)
#  description   :text
#  web_link      :string(255)
#  startup_id    :integer(4)      default(0)
#  parent_id     :integer(4)      default(0)
#  created_at    :datetime        not null
#  updated_at    :datetime        not null
#  model_id      :integer(4)
#

require 'test_helper'

class SceneTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
