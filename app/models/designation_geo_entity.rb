class DesignationGeoEntity < ActiveRecord::Base
  attr_accessible :designation_id, :geo_entity_id
  belongs_to :designation
end
