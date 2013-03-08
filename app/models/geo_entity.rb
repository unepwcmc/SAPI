# == Schema Information
#
# Table name: geo_entities
#
#  id                 :integer          not null, primary key
#  geo_entity_type_id :integer          not null
#  name_en            :string(255)      not null
#  long_name          :string(255)
#  iso_code2          :string(255)
#  iso_code3          :string(255)
#  legacy_id          :integer
#  legacy_type        :string(255)
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  is_current         :boolean          default(TRUE)
#  name_fr            :string(255)
#  name_es            :string(255)
#

class GeoEntity < ActiveRecord::Base
  attr_accessible :geo_entity_type_id, :iso_code2, :iso_code3,
    :legacy_id, :legacy_type, :long_name, :name_en, :name_es, :name_fr
  translates :name
  belongs_to :geo_entity_type
  has_many :geo_relationships, :dependent => :destroy
  has_many :distributions
  validates :geo_entity_type_id, :presence => true
  validates :iso_code2, :uniqueness => true, :allow_blank => true
  validates :iso_code2, :presence => true, :length => {:is => 2},
    :if => :is_country?
  validates :iso_code3, :uniqueness => true, :length => {:is => 3},
    :allow_blank => true, :if => :is_country?

  # geo entities containing those given by ids
  scope :containing_geo_entities, lambda { |geo_entity_ids|
    select("#{table_name}.*").
    joins(:geo_relationships => [:geo_relationship_type, :related_geo_entity]).
    where("geo_relationship_types.name = '#{GeoRelationshipType::CONTAINS}'").
    where("related_geo_entities_geo_relationships.id" => geo_entity_ids)
  }

  # geo entities contained in those given by ids
  scope :contained_geo_entities, lambda { |geo_entity_ids|
    select("related_geo_entities_geo_relationships.*").
    where(:id => geo_entity_ids).
    joins(:geo_relationships => [:geo_relationship_type, :related_geo_entity]).
    where("geo_relationship_types.name = '#{GeoRelationshipType::CONTAINS}'")
  }

  scope :current, where(:is_current => true)

  def is_country?
    geo_entity_type.name == GeoEntityType::COUNTRY
  end

  def containing_geo_entities
    GeoEntity.containing_geo_entities(self.id)
  end

  def contained_geo_entities
    GeoEntity.contained_geo_entities(self.id)
  end

  def as_json(options={})
    super(:only =>[:id, :iso_code2], :methods => [:name])
  end

  def can_be_deleted?
    distributions.count == 0
  end

end
