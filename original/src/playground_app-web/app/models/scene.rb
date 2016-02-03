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
# See the SceneStatus module for appropriate values of status

class Scene < ActiveRecord::Base
  attr_accessible :description, :first_banner, :second_banner, :title, :web_link

  belongs_to :author, class_name: 'User', foreign_key: :user_id
  has_many :script_files, class_name: 'DataFile', foreign_key: :scene_id, 
  					conditions: "content_type = #{ContentType::Script}", dependent: :destroy
  has_many :model_files, class_name: 'DataFile', foreign_key: :scene_id, 
  					conditions: "content_type = #{ContentType::Model}", dependent: :destroy

  # The main_script will be loaded first when running the scene
  belongs_to :main_script, class_name: 'DataFile', foreign_key: :startup_id

  # The main_model is really nothing special...it just gets displayed on the 
  # scene edit page as opposed to the additional files page
  belongs_to :main_model, class_name: 'DataFile', foreign_key: :model_id

  # When an approved scene is edited, a "child" copy of it is created and linked
  # to its parent. When the edited version is approved, it should replace the parent
  has_one :child, class_name: 'Scene', foreign_key: :parent_id, dependent: :destroy
  belongs_to :parent, class_name: 'Scene', foreign_key: :parent_id

  # For Proteopedia imports
  #
  has_many :green_links, class_name: 'GreenLink', foreign_key: :scene_id, dependent: :destroy, order: 'position'

  validates :title, presence: true, length: { in: 3..255 }
  validates :first_banner, presence: true, length: { maximum: 255 }
  validates :second_banner, length: { maximum: 255 }
  validates :description, presence: true
  validates :web_link, link_format: true
end
