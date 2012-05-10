# == Schema Information
#
# Table name: ranks
#
#  id         :integer         not null, primary key
#  name       :string(255)     not null
#  parent_id  :integer
#  created_at :datetime        not null
#  updated_at :datetime        not null
#

class Rank < ActiveRecord::Base
  attr_accessible :name, :parent_id
end
