# == Schema Information
#
# Table name: data_files
#
#  id           :integer(4)      not null, primary key
#  filename     :string(255)
#  data         :binary(21474836
#  scene_id     :integer(4)
#  content_type :integer(4)      default(0)
#  created_at   :datetime        not null
#  updated_at   :datetime        not null
#

require 'test_helper'

class DataFileTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
