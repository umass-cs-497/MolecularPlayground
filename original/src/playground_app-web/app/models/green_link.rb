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

class GreenLink < ActiveRecord::Base
  attr_accessible :active, :model_id, :position, :scene_id, :script_id, :title

  belongs_to :scene
  belongs_to :model_file, class_name: 'DataFile', foreign_key: :model_id, dependent: :destroy
  belongs_to :script_file, class_name: 'DataFile', foreign_key: :script_id, dependent: :destroy
  belongs_to :image

end
