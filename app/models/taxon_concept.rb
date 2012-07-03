# == Schema Information
#
# Table name: taxon_concepts
#
#  id                   :integer          not null, primary key
#  parent_id            :integer
#  lft                  :integer
#  rgt                  :integer
#  rank_id              :integer          not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  spcrecid             :integer
#  depth                :integer
#  designation_id       :integer          not null
#  taxon_name_id        :integer          not null
#  legacy_id            :integer
#  inherit_distribution :boolean          default(TRUE), not null
#  inherit_references   :boolean          default(TRUE), not null
#  data                 :hstore
#  not_in_cites         :boolean          default(FALSE), not null
#  fully_covered        :boolean          default(TRUE), not null
#  listing              :hstore
#

class TaxonConcept < ActiveRecord::Base
  attr_accessible :lft, :parent_id, :rgt, :rank_id, :parent_id,
    :designation_id, :taxon_name_id, :not_in_cites, :fully_covered,
    :data
  serialize :data, ActiveRecord::Coders::Hstore
  serialize :listing, ActiveRecord::Coders::Hstore

  belongs_to :rank
  belongs_to :designation
  belongs_to :taxon_name
  has_many :relationships, :class_name => 'TaxonRelationship',
    :dependent => :destroy
  has_many :related_taxon_concepts, :class_name => 'TaxonConcept',
    :through => :relationships
  has_many :taxon_concept_geo_entities
  has_many :geo_entities, :through => :taxon_concept_geo_entities
  has_many :listing_changes
  has_many :species_listings, :through => :listing_changes

  scope :checklist, select('taxon_concepts.id, taxon_concepts.depth,
    taxon_concepts.lft, taxon_concepts.rgt, taxon_concepts.parent_id,
    taxon_names.scientific_name, ranks.name AS rank_name').
    joins(:taxon_name).
    joins(:rank)

  acts_as_nested_set

  [
    :kingdom_name, :phylum_name, :class_name, :order_name, :family_name,
    :genus_name, :species_name, :subspecies_name, :full_name, :rank_name,
    :taxonomic_position, :spp
  ].each do |attr_name|
    define_method(attr_name) { data && data[attr_name.to_s] }
  end

  def cites_listed
    listing && listing['cites_listed'] == 't'
  end

  def cites_show
    listing && listing['cites_show'] == 't'
  end

  def current_listing
    listing && listing['cites_listing']
  end

  def as_json(options={})
    super(
      :only =>[:id, :parent_id, :depth],
      :methods => [:family_name, :class_name, :full_name, :rank_name, :spp,
      :taxonomic_position, :current_listing]
    )
  end

class << self

  def by_cites_appendices(appendix_abbreviations)
    return scoped if appendix_abbreviations.empty?
    conds = []
    appendix_abbreviations.each do |abbr|
      conds << "listing->'cites_#{abbr}' = '#{abbr}'"
    end
    where(conds.join(' AND '))
  end

  def by_geo_entities(geo_entities_ids)
    return scoped if geo_entities_ids.empty?
    in_clause = geo_entities_ids.join(',')
    where(:"geo_relationship_types.name" => 'CONTAINS')

    where <<-SQL
    taxon_concepts.id IN 
    (
    SELECT taxon_concepts.id
    FROM taxon_concepts
    INNER JOIN taxon_concept_geo_entities
      ON taxon_concepts.id = taxon_concept_geo_entities.taxon_concept_id
    WHERE taxon_concept_geo_entities.geo_entity_id IN (#{in_clause})

    UNION

    SELECT DISTINCT taxon_concepts.id
    FROM taxon_concepts
    INNER JOIN taxon_concept_geo_entities
      ON taxon_concepts.id = taxon_concept_geo_entities.taxon_concept_id
    INNER JOIN geo_entities
      ON taxon_concept_geo_entities.geo_entity_id = geo_entities.id
    INNER JOIN geo_relationships
      ON geo_entities.id = geo_relationships.other_geo_entity_id
    INNER JOIN geo_relationship_types
      ON geo_relationships.geo_relationship_type_id = geo_relationship_types.id
    INNER JOIN geo_entities related_geo_entities
      ON geo_relationships.geo_entity_id = related_geo_entities.id
    WHERE
      related_geo_entities.id IN (#{in_clause})
      AND 
      geo_relationship_types.name = '#{GeoRelationshipType::CONTAINS}'
    )
    SQL
  end
end

end
