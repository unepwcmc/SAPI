class GeoEntity < ActiveRecord::Base
  attr_accessible :geo_entity_type_id, :iso_code2, :iso_code3, :legacy_id,
    :legacy_type, :long_name, :name
  belongs_to :geo_entity_type
  has_many :relationships, :class_name => 'GeoRelationship',
    :dependent => :destroy
  has_many :related_geo_entities, :class_name => 'GeoEntity',
    :through => :relationships
  has_many :taxon_concept_geo_entities

  def as_json(options={})
    super(:only =>[:id, :name])
  end

end
