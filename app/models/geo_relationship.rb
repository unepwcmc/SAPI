# == Schema Information
#
# Table name: geo_relationships
#
#  id                       :integer          not null, primary key
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  geo_entity_id            :integer          not null
#  geo_relationship_type_id :integer          not null
#  other_geo_entity_id      :integer          not null
#
# Foreign Keys
#
#  geo_relationships_geo_entity_id_fk             (geo_entity_id => geo_entities.id)
#  geo_relationships_geo_relationship_type_id_fk  (geo_relationship_type_id => geo_relationship_types.id)
#  geo_relationships_other_geo_entity_id_fk       (other_geo_entity_id => geo_entities.id)
#

class GeoRelationship < ApplicationRecord
  # Migrated to controller (Strong Parameters)
  # attr_accessible :geo_entity_id, :geo_relationship_type_id, :other_geo_entity_id
  belongs_to :geo_relationship_type
  belongs_to :geo_entity
  belongs_to :related_geo_entity, :class_name => 'GeoEntity', :foreign_key => :other_geo_entity_id
end
