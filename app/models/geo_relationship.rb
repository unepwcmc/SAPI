# == Schema Information
#
# Table name: geo_relationships
#
#  id                       :integer          not null, primary key
#  geo_entity_id            :integer          not null
#  other_geo_entity_id      :integer          not null
#  geo_relationship_type_id :integer          not null
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#

class GeoRelationship < ActiveRecord::Base
  attr_accessible :geo_entity_id, :geo_relationship_type_id, :other_geo_entity_id
  belongs_to :geo_relationship_type
  belongs_to :geo_entity
  belongs_to :related_geo_entity, :class_name => 'GeoEntity', :foreign_key => :other_geo_entity_id
end
