# == Schema Information
#
# Table name: regions
#
#  id         :integer         not null, primary key
#  name       :string(255)     not null
#  created_at :datetime        not null
#  updated_at :datetime        not null
#

class Region < ActiveRecord::Base
  has_many :distribution_components, :as => :component
end
