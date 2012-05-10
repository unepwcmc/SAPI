# == Schema Information
#
# Table name: designations
#
#  id         :integer         not null, primary key
#  name       :string(255)     not null
#  created_at :datetime        not null
#  updated_at :datetime        not null
#

class Designation < ActiveRecord::Base
  attr_accessible :name
end
