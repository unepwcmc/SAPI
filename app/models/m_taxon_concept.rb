# == Schema Information
#
# Table name: taxon_concepts_mview
#
#  id                               :integer          primary key
#  parent_id                        :integer
#  designation_is_cites             :boolean
#  full_name                        :text
#  rank_name                        :text
#  cites_accepted                   :boolean
#  kingdom_position                 :integer
#  taxonomic_position               :text
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
#  cites_i                          :text
#  cites_ii                         :text
#  cites_iii                        :text
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

  scope :by_designation, lambda { |name|
    where("designation_is_#{name}".downcase => 't')
  }
  scope :without_nc, where(
    <<-SQL
    (cites_deleted <> 't' OR cites_deleted IS NULL)
    AND cites_listed IS NOT NULL AND cites_name_status = 'A'
    SQL
  )

  scope :without_hidden, where("cites_show = 't'")

  scope :by_cites_populations_and_appendices, lambda { |cites_regions_ids, countries_ids, appendix_abbreviations=nil|
    geo_entity_ids = countries_ids
    if cites_regions_ids
      geo_entity_ids += GeoEntity.contained_geo_entities(cites_regions_ids)
    end
    geo_entities_in_clause = geo_entity_ids.compact.join(',')
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
        FROM listing_changes
        INNER JOIN change_types ON change_types.id = listing_changes.change_type_id
        INNER JOIN listing_distributions ON listing_changes.id = listing_distributions.listing_change_id AND NOT is_party
        #{(appendix_abbreviations ? 'INNER JOIN species_listings ON species_listings.id = listing_changes.species_listing_id' : '')}
        WHERE is_current = 't' AND change_types.name = 'ADDITION'
        AND listing_distributions.geo_entity_id IN (#{geo_entities_in_clause})
        #{(appendix_abbreviations ? "AND species_listings.abbreviation IN (#{appendices_in_clause})" : '')}

        UNION
        (
          -- occurs in specified geo entities
          SELECT taxon_concept_geo_entities.taxon_concept_id
          FROM taxon_concept_geo_entities
          WHERE taxon_concept_geo_entities.geo_entity_id IN (#{geo_entities_in_clause})

          INTERSECT

          -- has listing changes that do not have distribution attached
          SELECT taxon_concept_id
          FROM listing_changes
          INNER JOIN change_types ON change_types.id = listing_changes.change_type_id
          #{(appendix_abbreviations ? 'INNER JOIN species_listings ON species_listings.id = listing_changes.species_listing_id' : '')}
          LEFT JOIN listing_distributions ON listing_changes.id = listing_distributions.listing_change_id AND NOT is_party
          WHERE is_current = 't' AND change_types.name = 'ADDITION'
          #{(appendix_abbreviations ? "AND species_listings.abbreviation IN (#{appendices_in_clause})" : '')}
          AND listing_distributions.id IS NULL

          EXCEPT

          -- and does not have an exclusion for the specified geo entities
          (
          #{
          geo_entity_ids.map do |geo_entity_id|
          <<-GEO_SQL
            SELECT taxon_concept_id
            FROM listing_changes
            INNER JOIN change_types ON change_types.id = listing_changes.change_type_id
            INNER JOIN listing_distributions ON listing_changes.id = listing_distributions.listing_change_id AND NOT is_party
            #{(appendix_abbreviations ? 'INNER JOIN species_listings ON species_listings.id = listing_changes.species_listing_id' : '')}
            WHERE is_current = 't' AND change_types.name = 'EXCEPTION'
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
    lower = scientific_name.sub(/^\s+/, '').sub(/\s+$/, '').sub(/\s+/,' ').
      capitalize
    upper = lower[0..lower.length - 2] +
      lower[lower.length - 1].next
    joins(
      <<-SQL
      INNER JOIN (
        SELECT id FROM taxon_concepts_mview
        WHERE full_name >= '#{lower}' AND full_name < '#{upper}'
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

end
