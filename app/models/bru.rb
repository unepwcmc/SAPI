# == Schema Information
#
# Table name: brus
#
#  id         :integer         not null, primary key
#  code       :string(255)     not null
#  level      :integer         not null
#  name       :string(255)
#  parent_id  :integer
#  country_id :integer
#  created_at :datetime        not null
#  updated_at :datetime        not null
#

class Bru < ActiveRecord::Base
  has_many :distribution_components, :as => :component
  belongs_to :country
end
