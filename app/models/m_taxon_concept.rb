# == Schema Information
#
# Table name: taxon_concepts_mview
#
#  id                               :integer          primary key
#  parent_id                        :integer
#  taxonomy_is_cites_eu             :boolean
#  full_name                        :string(255)
#  name_status                      :string(255)
#  rank_name                        :text
#  cites_accepted                   :boolean
#  kingdom_position                 :integer
#  taxonomic_position               :string(255)
#  kingdom_name                     :text
#  phylum_name                      :text
#  class_name                       :text
#  order_name                       :text
#  family_name                      :text
#  genus_name                       :text
#  species_name                     :text
#  subspecies_name                  :text
#  kingdom_id                       :integer
#  phylum_id                        :integer
#  class_id                         :integer
#  order_id                         :integer
#  family_id                        :integer
#  genus_id                         :integer
#  species_id                       :integer
#  subspecies_id                    :integer
#  cites_fully_covered              :boolean
#  cites_listed                     :boolean
#  cites_deleted                    :boolean
#  cites_excluded                   :boolean
#  cites_show                       :boolean
#  cites_i                          :boolean
#  cites_ii                         :boolean
#  cites_iii                        :boolean
#  current_listing                  :text
#  listing_updated_at               :datetime
#  specific_annotation_symbol       :text
#  generic_annotation_symbol        :text
#  generic_annotation_parent_symbol :text
#  author_year                      :string(255)
#  created_at                       :datetime
#  updated_at                       :datetime
#  taxon_concept_id_com             :integer
#  english_names_ary                :string
#  french_names_ary                 :string
#  spanish_names_ary                :string
#  taxon_concept_id_syn             :integer
#  synonyms_ary                     :string
#  synonyms_author_years_ary        :string
#  countries_ids_ary                :string
#  standard_references_ids_ary      :string
#  dirty                            :boolean
#  expiry                           :datetime
#

class MTaxonConcept < ActiveRecord::Base
  include PgArrayParser
  self.table_name = :taxon_concepts_mview
  self.primary_key = :id

  has_many :listing_changes, :foreign_key => :taxon_concept_id, :class_name => MListingChange
  has_many :current_listing_changes, :foreign_key => :taxon_concept_id,
    :class_name => MListingChange,
    :conditions => "is_current = 't' AND change_type_name <> 'EXCEPTION'"

  scope :by_cites_eu_taxonomy, where(:taxonomy_is_cites_eu => true)

  scope :without_nc, where(
    <<-SQL
    (cites_deleted <> 't' OR cites_deleted IS NULL)
    AND cites_listed IS NOT NULL AND name_status = 'A'
    SQL
  )

  scope :without_hidden, where("cites_show = 't'")

  scope :by_cites_populations_and_appendices, lambda { |cites_regions_ids, countries_ids, appendix_abbreviations=nil|
    geo_entity_ids = countries_ids
    if cites_regions_ids
      geo_entity_ids += GeoEntity.contained_geo_entities(cites_regions_ids).map(&:id)
    end
    geo_entities_in_clause = geo_entity_ids.compact.join(',')
    appendices_where_clause = if appendix_abbreviations
      (appendix_abbreviations & ['I', 'II', 'III']).map do |abbr|
        "cites_#{abbr} = TRUE"
      end.join(" OR ")
    else
      ''
    end
    appendices_in_clause = if appendix_abbreviations
      appendix_abbreviations.compact.map{ |a| "'#{a}'"}.join(',')
    else
      ''
    end

    joins(
      <<-SQL
      INNER JOIN (
        -- listed in specified geo entities
        SELECT taxon_concept_id
        FROM listing_changes_mview
        INNER JOIN listing_distributions ON listing_changes_mview.id = listing_distributions.listing_change_id AND NOT is_party
        #{(appendix_abbreviations ? 'INNER JOIN species_listings ON species_listings.id = listing_changes_mview.species_listing_id' : '')}
        WHERE is_current = 't' AND change_type_name = 'ADDITION'
        AND listing_distributions.geo_entity_id IN (#{geo_entities_in_clause})
        #{(appendix_abbreviations ? "AND species_listings.abbreviation IN (#{appendices_in_clause})" : '')}

        UNION
        (
          -- not on level of listing but occurs in specified geo entities
          SELECT taxon_concepts_mview.id
          FROM taxon_concepts_mview
          INNER JOIN distributions
            ON distributions.taxon_concept_id = taxon_concepts_mview.id
          WHERE distributions.geo_entity_id IN (#{geo_entities_in_clause})
            AND cites_listed = FALSE
            #{(appendix_abbreviations ? "AND (#{appendices_where_clause})" : '')}
        )

        UNION
        (
          -- occurs in specified geo entities
          SELECT distributions.taxon_concept_id
          FROM distributions
          WHERE distributions.geo_entity_id IN (#{geo_entities_in_clause})

          INTERSECT

          -- has listing changes that do not have distribution attached
          SELECT taxon_concept_id
          FROM listing_changes_mview
          #{(appendix_abbreviations ? 'INNER JOIN species_listings ON species_listings.id = listing_changes_mview.species_listing_id' : '')}
          LEFT JOIN listing_distributions ON listing_changes_mview.id = listing_distributions.listing_change_id AND NOT is_party
          WHERE is_current = 't' AND change_type_name = 'ADDITION'
          #{(appendix_abbreviations ? "AND species_listings.abbreviation IN (#{appendices_in_clause})" : '')}
          AND listing_distributions.id IS NULL

          EXCEPT

          -- and does not have an exclusion for the specified geo entities
          (
          #{
            geo_entity_ids.map do |geo_entity_id|
              <<-GEO_SQL
                SELECT taxon_concept_id
                FROM listing_changes_mview
                INNER JOIN listing_distributions ON listing_changes_mview.id = listing_distributions.listing_change_id AND NOT is_party
                #{(appendix_abbreviations ? 'INNER JOIN species_listings ON species_listings.id = listing_changes_mview.species_listing_id' : '')}
                WHERE is_current = 't' AND change_type_name = 'EXCEPTION'
                #{(appendix_abbreviations ? "AND species_listings.abbreviation IN (#{appendices_in_clause})" : '')}
                AND listing_distributions.geo_entity_id = #{geo_entity_id}
              GEO_SQL
            end.join ("\n            INTERSECT\n\n")
          }
          )

        )
      ) taxa_in_populations ON #{self.table_name}.id = taxa_in_populations.taxon_concept_id
      SQL
    )
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
        SELECT id FROM taxon_concepts_mview
        WHERE full_name >= '#{TaxonName.lower_bound(scientific_name)}'
          AND full_name < '#{TaxonName.upper_bound(scientific_name)}'
      ) matches
      ON matches.id IN (taxon_concepts_mview.id, family_id, order_id, class_id, phylum_id)
      SQL
    )
  }

  scope :at_level_of_listing, where(:cites_listed => 't')

  scope :taxonomic_layout, order('taxonomic_position')
  scope :alphabetical_layout, order(['kingdom_position', 'full_name'])

  def spp
    if ['GENUS', 'FAMILY', 'SUBFAMILY', 'ORDER'].include?(rank_name)
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
  end

  def synonyms
    db_ary_to_array :synonyms_ary
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
    if respond_to?(:countries_ids_ary) && countries_ids_ary?
      parse_pg_array(countries_ids_ary || '').compact
    elsif respond_to? :tc_countries_ids_ary
      parse_pg_array(tc_countries_ids_ary || '').compact
    else
      []
    end
  end

  def countries_iso_codes
    CountryDictionary.instance.get_iso_codes_by_ids(countries_ids)
  end

  def countries_full_names
    CountryDictionary.instance.get_names_by_ids(countries_ids)
  end

  def recently_changed
    return (listing_updated_at ? listing_updated_at > 8.year.ago : false)
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

  ['English', 'Spanish', 'French'].each do |lng|
    ["generic_#{lng.downcase}_full_note", "#{lng.downcase}_full_note"].each do |method_name|
      define_method(method_name) do
        current_listing_changes.map do |lc|
          note = lc.send(method_name)
          note && "Appendix #{lc.species_listing_name}:" + note || ''
        end.join("\n")
      end
    end
  end

  # returns ancestor from whom listing is inherited
  def closest_listed_ancestor
    # TODO we should precalculate this ancestor
    return self if cites_listed
    if cites_listed == false
      MTaxonConcept.where(
      <<-SQL
      id IN (
        WITH RECURSIVE ancestors AS (
          SELECT h.id, h.parent_id, h.cites_listed, h.taxonomic_position
          FROM #{MTaxonConcept.table_name} h
          WHERE h.id = #{self.id}

          UNION ALL

          SELECT hi.id, hi.parent_id, hi.cites_listed, hi.taxonomic_position
          FROM ancestors
          JOIN #{MTaxonConcept.table_name} hi ON hi.id = ancestors.parent_id
        )
        SELECT id FROM ancestors
        WHERE cites_listed = TRUE
        ORDER BY taxonomic_position DESC
        LIMIT 1
      )
      SQL
      ).first
    else
      nil
    end
  end

  # returns the ids of parties associated with current listing changes
  def current_party_ids
    if current_listing_changes.size > 0
      current_listing_changes.
        where(:change_type_name => ChangeType::ADDITION).map(&:party_id)
    else
      #inherited listing -- find closest ancestor with listing changes
      closest_listed_ancestor &&
        closest_listed_ancestor.current_listing_changes.
        where(:change_type_name => ChangeType::ADDITION).map(&:party_id) || []
    end
  end

end
