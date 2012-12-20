# == Schema Information
#
# Table name: geo_relationship_types
#
#  id         :integer          not null, primary key
#  name       :string(255)      not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class GeoRelationshipType < ActiveRecord::Base
  attr_accessible :name

  include Dictionary
  build_dictionary :contains, :intersects

end
