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
  include PgArrayParser
  attr_accessible :lft, :parent_id, :rgt, :rank_id, :parent_id,
    :designation_id, :taxon_name_id, :not_in_cites, :fully_covered,
    :data
  attr_accessor :listing_history
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
  has_many :taxon_commons, :dependent => :destroy
  has_many :common_names, :through => :taxon_commons

  scope :taxonomic_layout, where("data -> 'rank_name' <> 'GENUS'").
    order("data -> 'taxonomic_position'")
  scope :alphabetical_layout, where(
      "data -> 'rank_name' NOT IN (?)",
      [Rank::CLASS, Rank::PHYLUM, Rank::KINGDOM]
    ).
    order("data -> 'full_name'")
  scope :with_common_names, select(['E', 'S', 'F'].map do |lng|
        "lng_#{lng.downcase}"
      end).
      joins(
        <<-SQL
        LEFT JOIN (
          SELECT *
          FROM
          CROSSTAB(
            'SELECT taxon_concepts.id AS taxon_concept_id_cn,
            SUBSTRING(languages.name FROM 1 FOR 1) AS lng,
            ARRAY_AGG(common_names.name ORDER BY common_names.id) AS common_names_ary 
            FROM "taxon_concepts"
            INNER JOIN "taxon_commons"
              ON "taxon_commons"."taxon_concept_id" = "taxon_concepts"."id" 
            INNER JOIN "common_names"
              ON "common_names"."id" = "taxon_commons"."common_name_id" 
            INNER JOIN "languages"
              ON "languages"."id" = "common_names"."language_id"
            GROUP BY taxon_concepts.id, SUBSTRING(languages.name FROM 1 FOR 1)
            ORDER BY 1,2'
          ) AS ct(
            taxon_concept_id_cn INTEGER,
            lng_E VARCHAR[], lng_F VARCHAR[], lng_S VARCHAR[]
          )
        ) common_names ON taxon_concepts.id = common_names.taxon_concept_id_cn
        SQL
      )

  acts_as_nested_set

  [
    :kingdom_name, :phylum_name, :class_name, :order_name, :family_name,
    :genus_name, :species_name, :subspecies_name, :full_name, :rank_name,
    :taxonomic_position
  ].each do |attr_name|
    define_method(attr_name) { data && data[attr_name.to_s] }
  end

  #this means the taxon is listed explicitly
  def cites_listed
    listing && listing['cites_listed'] == 't'
  end

  def cites_nc
    listing && listing['cites_nc'] == 't'
  end

  def cites_del
    listing && listing['cites_del'] == 't'
  end

  def cites_show
    listing && listing['cites_show'] == 't'
  end

  def current_listing
    listing && listing['cites_listing']
  end

  ['English', 'Spanish', 'French'].each do |lng|
    define_method(lng.downcase) do
      sym = :"lng_#{lng[0].downcase}"
      if respond_to?(sym)
        parse_pg_array(send(sym) || '').map{ |e| e.force_encoding('utf-8') }.join(', ')
      else
        nil
      end
    end
  end

  def spp
    if ['GENUS', 'FAMILY', 'ORDER'].include?(rank_name)
      'spp.'
    else
      nil
    end
  end

  def as_json(options={})
    super(
      :only =>[:id, :parent_id, :depth],
      :methods => [:family_name, :class_name, :full_name, :rank_name, :spp,
      :taxonomic_position, :current_listing, :english, :spanish, :french]
    )
  end

class << self

  def by_cites_appendices(appendix_abbreviations)
    return scoped if appendix_abbreviations.empty?
    conds = []
    if appendix_abbreviations.include? 'del'
      conds << "listing->'cites_del' = 't'"
    end
    if appendix_abbreviations.include? 'nc'
      conds << "listing->'cites_listing'= ''"
    end
    (appendix_abbreviations - ['del','nc']).each do |abbr|
      conds << "listing->'cites_#{abbr}' = '#{abbr}'"
    end
    where(conds.join(' OR '))
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
