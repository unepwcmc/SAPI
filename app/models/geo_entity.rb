# == Schema Information
#
# Table name: geo_entities
#
#  id                 :integer         not null, primary key
#  geo_entity_type_id :integer         not null
#  name               :string(255)     not null
#  long_name          :string(255)
#  iso_code2          :string(255)
#  iso_code3          :string(255)
#  legacy_id          :integer
#  legacy_type        :string(255)
#  created_at         :datetime        not null
#  updated_at         :datetime        not null
#

class GeoEntity < ActiveRecord::Base
  attr_accessible :geo_entity_type_id, :iso_code2, :iso_code3, :legacy_id, :legacy_type, :long_name, :name
  belongs_to :geo_entity_type
  has_many :relationships, :class_name => 'GeoRelationship', :dependent => :destroy
  has_many :related_geo_entities, :class_name => 'GeoEntity', :through => :relationships
  has_many :taxon_concept_geo_entities

  def as_json(options={})
    super(:only =>[:id, :name])
  end

end
