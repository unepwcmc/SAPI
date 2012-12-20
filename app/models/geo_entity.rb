# == Schema Information
#
# Table name: geo_entities
#
#  id                 :integer          not null, primary key
#  geo_entity_type_id :integer          not null
#  name               :string(255)      not null
#  long_name          :string(255)
#  iso_code2          :string(255)
#  iso_code3          :string(255)
#  legacy_id          :integer
#  legacy_type        :string(255)
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  is_current         :boolean          default(TRUE)
#

class GeoEntity < ActiveRecord::Base
  attr_accessible :geo_entity_type_id, :iso_code2, :iso_code3,
    :legacy_id, :legacy_type, :long_name, :name_en, :name_es, :name_fr
  translates :name
  belongs_to :geo_entity_type
  has_many :relationships, :class_name => 'GeoRelationship', :dependent => :destroy
  has_many :related_geo_entities, :class_name => 'GeoEntity', :through => :relationships
  has_many :taxon_concept_geo_entities
  #validates if it is a country, it should have an iso code TODO

  scope :contained_geo_entities, lambda { |geo_entity_ids|
    select("related_geo_entities_geo_relationships.*").
    where(:id => geo_entity_ids).
    joins(:relationships => [:geo_relationship_type, :related_geo_entity]).
    where("geo_relationship_types.name = '#{GeoRelationshipType::CONTAINS}'")

  }
  scope :current, where(:is_current => true)

  def as_json(options={})
    super(:only =>[:id, :name, :iso_code2])
  end

end
