class GeoRelationship < ActiveRecord::Base
  attr_accessible :geo_entity_id, :geo_relationship_type, :other_geo_entity_id
  belongs_to :geo_relationship_type
  belongs_to :related_geo_entity, :foreign_key => :other_geo_entity_id
end
