# == Schema Information
#
# Table name: references
#
#  id         :integer         not null, primary key
#  title      :string(255)     not null
#  year       :string(255)
#  created_at :datetime        not null
#  updated_at :datetime        not null
#

class Reference < ActiveRecord::Base
  attr_accessible :title, :year
end
