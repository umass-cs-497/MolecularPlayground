# == Schema Information
#
# Table name: images
#
#  id         :integer(4)      not null, primary key
#  data       :binary(16777215
#  created_at :datetime        not null
#  updated_at :datetime        not null
#

class Image < ActiveRecord::Base
  # attr_accessible :title, :body
end
