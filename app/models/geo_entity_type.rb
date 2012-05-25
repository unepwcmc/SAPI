# == Schema Information
#
# Table name: geo_entity_types
#
#  id         :integer         not null, primary key
#  name       :string(255)     not null
#  created_at :datetime        not null
#  updated_at :datetime        not null
#

class GeoEntityType < ActiveRecord::Base
  attr_accessible :name
end
