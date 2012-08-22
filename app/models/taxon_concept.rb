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
#  data                 :hstore
#  fully_covered        :boolean          default(TRUE), not null
#  listing              :hstore
#

class TaxonConcept < ActiveRecord::Base
  include PgArrayParser
  attr_accessible :lft, :parent_id, :rgt, :rank_id, :parent_id,
    :designation_id, :taxon_name_id, :fully_covered,
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
  has_and_belongs_to_many :references, :join_table => :taxon_concept_references

  scope :by_designation, lambda { |name|
    joins(:designation).where('designations.name' => name)
  }
  scope :without_nc, lambda { |layout|
    if layout.blank? || layout == :alphabetical
      where("(listing->'cites_listed')::BOOLEAN IS NOT NULL")
    else
      where(
        "(listing->'cites_listed')::BOOLEAN IS NOT NULL
        OR listing->'cites_listed_children' = 't'"
      )
    end
  }
  scope :taxonomic_layout, order("taxon_concepts.data -> 'taxonomic_position'")
  scope :alphabetical_layout, where(
      "taxon_concepts.data -> 'rank_name' NOT IN (?)",
      [Rank::CLASS, Rank::PHYLUM, Rank::KINGDOM]
    ).
    order("taxon_concepts.data -> 'full_name'")
  scope :with_common_names, lambda { |lng_ary|
      select(lng_ary.map do |lng|
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
  }
  scope :with_synonyms, select(:synonyms_ary).
    joins(
      <<-SQL
      INNER JOIN (
        SELECT taxon_concepts.id AS taxon_concept_id_ws, ARRAY_AGG(synonym_tc.data->'full_name') AS synonyms_ary
        FROM taxon_concepts
        LEFT JOIN taxon_relationships
          ON "taxon_relationships"."taxon_concept_id" = "taxon_concepts"."id"
        LEFT JOIN "taxon_relationship_types"
          ON "taxon_relationship_types"."id" = "taxon_relationships"."taxon_relationship_type_id"
        LEFT JOIN taxon_concepts AS synonym_tc
          ON synonym_tc.id = taxon_relationships.other_taxon_concept_id
        GROUP BY taxon_concepts.id
      ) synonym_names ON taxon_concepts.id = synonym_names.taxon_concept_id_ws
      SQL
    )
  scope :with_standard_references, select(:std_ref_ary).joins(
    <<-SQL
    LEFT JOIN (
      WITH RECURSIVE q AS (
        SELECT h, h.id, ARRAY_AGG(reference_id) AS std_ref_ary
        FROM taxon_concepts h
        LEFT JOIN taxon_concept_references
        ON h.id = taxon_concept_references.taxon_concept_id
          AND taxon_concept_references.data->'usr_is_std_ref' = 't'
        WHERE h.parent_id IS NULL
        GROUP BY h.id

        UNION ALL

        SELECT hi, hi.id,
          CASE
            WHEN (hi.data->'usr_no_std_ref')::BOOLEAN = 't' THEN ARRAY[]::INTEGER[]
            ELSE std_ref_ary || reference_id
          END
        FROM q
        JOIN taxon_concepts hi ON hi.parent_id = (q.h).id
        LEFT JOIN taxon_concept_references
        ON hi.id = taxon_concept_references.taxon_concept_id
          AND taxon_concept_references.data->'usr_is_std_ref' = 't'
      )
      SELECT id AS taxon_concept_id_sr,
      ARRAY(SELECT DISTINCT * FROM UNNEST(std_ref_ary) s WHERE s IS NOT NULL)
      AS std_ref_ary
      FROM q
    ) standard_references ON taxon_concepts.id = standard_references.taxon_concept_id_sr
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

  def cites_accepted
    data && data['cites_accepted'] == 't'
  end

  #here go the CITES listing flags
  [
    :cites_listed,#taxon is listed explicitly
    :cites_listed_children,#taxon has children listed
    :usr_cites_exclusion,#taxon is excluded from it's parent's listing
    :cites_exclusion,#taxon's ancestor is excluded from it's parent's listing
    :cites_del,#taxon has been deleted from appendices
    :cites_show#@taxon should be shown in checklist even if NC
  ].each do |attr_name|
    define_method(attr_name) { listing && listing[attr_name.to_s] == 't' }
  end

  def current_listing
    listing && listing['cites_listing']
  end

  ['English', 'Spanish', 'French'].each do |lng|
    define_method("#{lng.downcase}_names") do
      sym = :"lng_#{lng[0].downcase}"
      if respond_to?(sym)
        parse_pg_array(send(sym) || '').compact.map do |e|
          e.force_encoding('utf-8')
        end
      else
        []
      end
    end

    define_method("#{lng.downcase}_names_list") do
      self.send("#{lng.downcase}_names").join(', ')
    end
  end

  def synonyms
    me = unless respond_to?(:synonyms_ary)
      TaxonConcept.with_synonyms.where(:id => self.id).first
    else
      self
    end
    if me.respond_to?(:synonyms_ary)
      parse_pg_array(me.synonyms_ary || '').compact.map do |e|
        e.force_encoding('utf-8')
      end
    else
      []
    end
  end

  def synonyms_list
    synonyms.join(', ')
  end

  #note this will probably return external reference ids in the future
  def standard_references
    me = unless respond_to?(:std_ref_ary)
      TaxonConcept.with_standard_references.where(:id => self.id).first
    else
      self
    end
    if me.respond_to?(:std_ref_ary)
      parse_pg_array(me.std_ref_ary || '').compact.map do |e|
        e.force_encoding('utf-8')
      end.map(&:to_i)
    else
      []
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
    puts options.inspect
    unless options[:only] || options[:methods]
      options = {
        :only =>[:id, :parent_id, :depth],
        :methods => [:family_name, :class_name, :full_name, :rank_name, :spp,
        :taxonomic_position, :current_listing, :english_names_list, :spanish_names_list, :french_names_list, 
        :synonyms_list, :cites_accepted]
      }
    end
    super(options)
  end

class << self

  def by_cites_appendices(appendix_abbreviations)
    return scoped if appendix_abbreviations.empty?
    conds = []
    if appendix_abbreviations.include? 'nc'
      conds << "(listing->'cites_del' = 't' AND listing->'cites_listing' = ''
        OR listing->'not_in_cites'= 'NC')"
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
