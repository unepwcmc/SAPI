# == Schema Information
#
# Table name: designation_geo_entities
#
#  id             :integer          not null, primary key
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  designation_id :integer          not null
#  geo_entity_id  :integer          not null
#
# Foreign Keys
#
#  designation_geo_entities_designation_id_fk  (designation_id => designations.id)
#  designation_geo_entities_geo_entity_id_fk   (geo_entity_id => geo_entities.id)
#

class DesignationGeoEntity < ApplicationRecord
  # Relationship table between Designation and GeoEntity.
  # attr_accessible :designation_id, :geo_entity_id
  belongs_to :designation
  belongs_to :geo_entity
end
