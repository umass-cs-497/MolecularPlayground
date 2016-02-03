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
# See the ContentType module for acceptable values of content_type

class DataFile < ActiveRecord::Base
  attr_accessible :content_type, :data, :filename
  belongs_to :scene

  # These two associations exist mainly to make sure the scene is updated correctly
  # if its main_model or main_scene are deleted.
  has_one :main_model_scene, class_name: 'Scene', foreign_key: :model_id, dependent: :nullify, inverse_of: :main_model
  has_one :main_script_scene, class_name: 'Scene', foreign_key: :startup_id, dependent: :nullify, inverse_of: :main_script
end
