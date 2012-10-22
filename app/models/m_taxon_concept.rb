# == Schema Information
#
# Table name: taxon_concepts_mview
#
#  id                          :integer          primary key
#  fully_covered               :boolean
#  designation_is_cites        :boolean
#  full_name                   :text
#  rank_name                   :text
#  cites_accepted              :boolean
#  kingdom_position            :integer
#  taxonomic_position          :text
#  kingdom_name                :text
#  phylum_name                 :text
#  class_name                  :text
#  order_name                  :text
#  family_name                 :text
#  genus_name                  :text
#  species_name                :text
#  subspecies_name             :text
#  kingdom_id                  :text
#  phylum_id                   :text
#  class_id                    :text
#  order_id                    :text
#  family_id                   :text
#  genus_id                    :text
#  species_id                  :text
#  subspecies_id               :text
#  cites_listed                :boolean
#  cites_show                  :boolean
#  cites_i                     :text
#  cites_ii                    :text
#  cites_iii                   :text
#  cites_del                   :boolean
#  current_listing             :text
#  usr_cites_exclusion         :boolean
#  cites_exclusion             :boolean
#  taxon_concept_id_com        :integer
#  english_names_ary           :string
#  french_names_ary            :string
#  spanish_names_ary           :string
#  taxon_concept_id_syn        :integer
#  synonyms_ary                :string
#  countries_ids_ary           :string
#  standard_references_ids_ary :string
#  dirty                       :boolean
#  expiry                      :datetime
#  listing_updated_at          :datetime
#  updated_at                  :datetime
#  created_at                  :datetime
#  specific_annotation_symbol  :string(255)
#  generic_annotation_symbol   :string(255)
#

class MTaxonConcept < ActiveRecord::Base
  include PgArrayParser
  self.table_name = :taxon_concepts_mview
  self.primary_key = :id

  has_many :m_listing_changes, :foreign_key => :taxon_concept_id
  has_many :current_m_listing_changes, :foreign_key => :taxon_concept_id, :class_name => MListingChange, :conditions => {:is_current => true}

  scope :by_designation, lambda { |name|
    where("designation_is_#{name}".downcase => 't')
  }
  scope :without_nc, where(
    <<-SQL
    (cites_del <> 't' OR cites_del IS NULL)
    AND cites_listed IS NOT NULL
    SQL
  )

  scope :without_hidden, where("cites_show = 't'")

  scope :by_cites_regions_and_countries, lambda { |cites_regions_ids, countries_ids|
    in_clause = [cites_regions_ids, countries_ids].flatten.compact.join(',')

    where <<-SQL
    taxon_concepts_mview.id IN 
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
  }
  scope :by_cites_appendices, lambda { |appendix_abbreviations|
    conds = 
    (['I','II','III'] & appendix_abbreviations).map do |abbr|
      "cites_#{abbr} = 't'"
    end
    where(conds.join(' OR '))
  }

  scope :by_scientific_name, lambda { |scientific_name|
    joins(
      <<-SQL
      INNER JOIN (
        WITH RECURSIVE q AS (
          SELECT h, h.id, data->'full_name' AS full_name_sci
          FROM taxon_concepts h
          WHERE data->'full_name' ILIKE '#{scientific_name}%'

          UNION ALL

          SELECT hi, hi.id, data->'full_name'
          FROM q
          JOIN taxon_concepts hi
          ON hi.parent_id = (q.h).id
        ) SELECT DISTINCT id, full_name_sci FROM q
      ) descendants ON #{self.table_name}.id = descendants.id
      SQL
    )
  }
  scope :at_level_of_listing, where(:cites_listed => 't')

  scope :taxonomic_layout, order('taxonomic_position')
  scope :alphabetical_layout, order(['kingdom_position', 'full_name'])

  def spp
    if ['GENUS', 'FAMILY', 'ORDER'].include?(rank_name)
      'spp.'
    else
      nil
    end
  end

  ['English', 'Spanish', 'French'].each do |lng|
    define_method("#{lng.downcase}_names") do
      sym = :"#{lng.downcase}_names_ary"
      db_ary_to_array(sym)
    end

    define_method("#{lng.downcase}_names_list") do
      self.send("#{lng.downcase}_names").join(', ')
    end
  end

  def synonyms
    db_ary_to_array :synonyms_ary
  end

  def synonyms_list
    synonyms.join(', ')
  end

  def db_ary_to_array ary
    if respond_to?(ary)
      parse_pg_array( send(ary)|| '').compact.map do |e|
        e.force_encoding('utf-8')
      end
    else
      []
    end
  end

  def matching_names
    (synonyms + english_names + french_names + spanish_names).flatten
  end

  def countries_ids
    if respond_to?(:countries_ids_ary)
      parse_pg_array(countries_ids_ary || '').compact
    else
      []
    end
  end

  def recently_changed
    return listing_updated_at > 8.year.ago
  end

  #note this will probably return external reference ids in the future
  def standard_references
    if respond_to?(:standard_references_ids_ary)
      parse_pg_array(standard_references_ids_ary || '').compact.map do |e|
        e.force_encoding('utf-8')
      end.map(&:to_i)
    else
      []
    end
  end

  def current_listing_changes
    current_m_listing_changes.map do |lc|
      lc.listing_attributes
    end
  end

  def as_json(options={})

    unless options[:only] || options[:methods]
      options = {
        :only =>[:id, :species_name, :genus_name, :family_name, :order_name,
          :class_name, :phylum_name, :full_name, :rank_name, :author_year,
          :taxonomic_position, :current_listing, :cites_accepted],
        :methods => [
          :spp, :recently_changed,
          :english_names_list, :spanish_names_list, :french_names_list,
          :synonyms_list, :countries_ids, :current_listing_changes
        ]
      }
    end
    super(options)
  end

end
