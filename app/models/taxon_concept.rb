# == Schema Information
#
# Table name: taxon_concepts
#
#  id             :integer          not null, primary key
#  parent_id      :integer
#  lft            :integer
#  rgt            :integer
#  rank_id        :integer          not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  designation_id :integer          not null
#  taxon_name_id  :integer          not null
#  legacy_id      :integer
#  data           :hstore
#  fully_covered  :boolean          default(TRUE), not null
#  listing        :hstore
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

  #scopes used for filtering
  scope :by_designation, lambda { |name|
    where("designation_is_#{name}" => 't')
  }
  scope :by_cites_regions_and_countries, lambda { |cites_regions_ids, countries_ids|
    in_clause = [cites_regions_ids, countries_ids].flatten.compact.join(',')

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
            SELECT h, h.id, data->'full_name' AS full_name
            FROM taxon_concepts h
            WHERE data->'full_name' ILIKE '#{scientific_name}%'

            UNION ALL

            SELECT hi, hi.id, data->'full_name'
            FROM q
            JOIN taxon_concepts hi
            ON hi.parent_id = (q.h).id
          ) SELECT DISTINCT id, full_name FROM q
        ) descendants ON taxon_concepts.id = descendants.id
        SQL
      )
  }

  scope :without_nc, where(
  <<-SQL
  (cites_del <> 't' OR cites_del IS NULL)
  AND (
    (
      rank_name = '#{Rank::SPECIES}' AND cites_listed IS NOT NULL
    )
    OR
    (
      rank_name <> '#{Rank::SPECIES}' AND cites_listed = 't'
    )
  )
  SQL
  )
  scope :taxonomic_layout, order('kingdom_position, taxonomic_position')
  scope :alphabetical_layout, order('kingdom_position, full_name')

  scope :with_countries_ids, select(:countries_ids_ary).
    joins(
      <<-SQL
      LEFT JOIN (
        SELECT taxon_concepts.id AS taxon_concept_id_wc,
        ARRAY_AGG(geo_entities.id ORDER BY geo_entities.name) AS countries_ids_ary
        FROM taxon_concepts
        LEFT JOIN taxon_concept_geo_entities
          ON "taxon_concept_geo_entities"."taxon_concept_id" = "taxon_concepts"."id"
        LEFT JOIN geo_entities
          ON taxon_concept_geo_entities.geo_entity_id = geo_entities.id
        LEFT JOIN "geo_entity_types"
          ON "geo_entity_types"."id" = "geo_entities"."geo_entity_type_id"
            AND geo_entity_types.name = '#{GeoEntityType::COUNTRY}'
        GROUP BY taxon_concepts.id
      ) countries_ids ON taxon_concepts.id = countries_ids.taxon_concept_id_wc
      SQL
    )
  scope :at_level_of_listing, where("cites_listed = 't'")
  scope :with_all, joins("LEFT JOIN taxon_concepts_mview ON taxon_concepts.id = taxon_concepts_mview.id")
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

  scope :with_history, select('listing_change_id_ary, effective_at_ary, change_type_name_ary,
    species_listing_name_ary, party_name_ary, notes_ary').
    joins("LEFT JOIN (
      SELECT taxon_concept_id, ARRAY_AGG(id) AS listing_change_id_ary,
      ARRAY_AGG(effective_at) AS effective_at_ary,
      ARRAY_AGG(change_type_name) AS change_type_name_ary,
      ARRAY_AGG(species_listing_name) AS species_listing_name_ary,
      ARRAY_AGG(party_name) AS party_name_ary, ARRAY_AGG(notes) AS notes_ary
      FROM mat_listing_changes_view
      --filter out deletion records that were added programatically to simplify
      --current listing calculations - don't want them to show up
      WHERE NOT (change_type_name = '#{ChangeType::DELETION}' AND species_listing_id IS NOT NULL)
      GROUP BY taxon_concept_id
    ) listing_changes_view_grouped
    ON taxon_concepts.id = listing_changes_view_grouped.taxon_concept_id")

  acts_as_nested_set

  [
    :kingdom_name, :phylum_name, :class_name, :order_name, :family_name,
    :genus_name, :species_name, :subspecies_name,
    :kingdom_id, :phylum_id, :class_id, :order_id, :family_id,
    :genus_id, :species_id, :subspecies_id,
    :full_name, :rank_name, :taxonomic_position
  ].each do |attr_name|
    define_method(attr_name) { data && data[attr_name.to_s] }
  end

  def cites_accepted
    data && data['cites_accepted'] == 't'
  end

  #here go the CITES listing flags
  [
    :cites_listed,#taxon is listed explicitly
    :usr_cites_exclusion,#taxon is excluded from it's parent's listing
    :cites_exclusion,#taxon's ancestor is excluded from it's parent's listing
    :cites_del,#taxon has been deleted from appendices
    :cites_show#@taxon should be shown in checklist even if NC
  ].each do |attr_name|
    define_method(attr_name) do
      listing && case listing[attr_name.to_s]
        when 't'
          true
        when 'f'
          false
        else
          nil
      end
    end
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


  def listing_history
    [:listing_change_id_ary, :effective_at_ary, :change_type_name_ary,
      :species_listing_name_ary, :party_name_ary, :notes_ary
    ].each do |ary|
      parsed_ary = if respond_to?(ary)
        parse_pg_array(send(ary) || '').map do |e|
          e.force_encoding('utf-8') if e
        end
        
      else
        []
      end
      instance_variable_set(:"@#{ary}", parsed_ary)
    end
    res = []
    @effective_at_ary.each_with_index do |date, i|
      event = {
        :id => @listing_change_id_ary[i],
        :effective_at => date,
        :change_type_name => @change_type_name_ary[i],
        :species_listing_name => @species_listing_name_ary[i],
        :party_name => @party_name_ary[i],
        :notes => @notes_ary[i]
      }
      res << event
    end
    res
  end

  def countries_ids
    me = unless respond_to?(:countries_ids_ary)
      TaxonConcept.with_countries.where(:id => self.id).first
    else
      self
    end
    if me.respond_to?(:countries_ids_ary)
      parse_pg_array(me.countries_ids_ary || '').compact
    else
      []
    end
  end

  def synonyms
    me = unless respond_to?(:synonyms_ary)
      TaxonConcept.with_all.where(:id => self.id).first
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

  def recently_changed
    return self.listing_changes.where('effective_at > ?', 8.year.ago).any?
  end

  def spp
    if ['GENUS', 'FAMILY', 'ORDER'].include?(rank_name)
      'spp.'
    else
      nil
    end
  end

  EXPORTED_FIELDS = [
    :id, :full_name, :spp, :rank_name, :current_listing, :cites_accepted,
    :species_name, :genus_name, :family_name, :order_name,
    :class_name, :phylum_name,
    :species_id, :genus_id, :family_id, :order_id,
    :class_id, :phylum_id,
    :english_names_list, :spanish_names_list, :french_names_list, 
    :synonyms_list, :countries_ids, :cites_accepted, :recently_changed
  ]

  def to_checklist_item
    Checklist::TaxonConceptItem.new(
      Hash[EXPORTED_FIELDS.map{ |field| [field, self.send(field)] }]
    )
  end

  #TODO ?
  def as_json(options={})
    unless options[:only] || options[:methods]
      options = {
        :only =>[:id, :parent_id],
        :methods => [:species_name, :genus_name, :family_name, :order_name,
          :class_name, :phylum_name, :full_name, :rank_name, :spp,
          :taxonomic_position, :current_listing,
          :english_names_list, :spanish_names_list, :french_names_list,
          :synonyms_list, :countries_ids, :cites_accepted, :recently_changed
        ]
      }
    end
    super(options)
  end

end
