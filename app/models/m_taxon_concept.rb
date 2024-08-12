# == Schema Information
#
# Table name: taxon_concepts_mview
#
#  id                                       :integer          primary key
#  all_distribution_ary_en                  :string           is an Array
#  all_distribution_ary_es                  :string           is an Array
#  all_distribution_ary_fr                  :string           is an Array
#  all_distribution_iso_codes_ary           :string           is an Array
#  ann_symbol                               :string(255)
#  author_year                              :string(255)
#  cites_accepted                           :boolean
#  cites_i                                  :boolean
#  cites_ii                                 :boolean
#  cites_iii                                :boolean
#  cites_listed                             :boolean
#  cites_listed_descendants                 :boolean
#  cites_listing                            :string(255)
#  cites_listing_original                   :string(255)
#  cites_listing_updated_at                 :datetime
#  cites_show                               :boolean
#  cites_status                             :string(255)
#  class_name                               :string(255)
#  cms_listed                               :boolean
#  cms_listing                              :string(255)
#  cms_listing_original                     :string(255)
#  cms_listing_updated_at                   :datetime
#  cms_show                                 :boolean
#  cms_status                               :string(255)
#  countries_ids_ary                        :integer          is an Array
#  dependents_updated_at                    :datetime
#  dirty                                    :boolean
#  english_names_ary                        :string           is an Array
#  eu_listed                                :boolean
#  eu_listing                               :string(255)
#  eu_listing_original                      :string(255)
#  eu_listing_updated_at                    :datetime
#  eu_show                                  :boolean
#  eu_status                                :string(255)
#  expiry                                   :timestamptz
#  extinct_distribution_ary_en              :string           is an Array
#  extinct_distribution_ary_es              :string           is an Array
#  extinct_distribution_ary_fr              :string           is an Array
#  extinct_uncertain_distribution_ary_en    :string           is an Array
#  extinct_uncertain_distribution_ary_es    :string           is an Array
#  extinct_uncertain_distribution_ary_fr    :string           is an Array
#  family_name                              :string(255)
#  french_names_ary                         :string           is an Array
#  full_name                                :string(255)
#  genus_name                               :string(255)
#  hash_ann_parent_symbol                   :string(255)
#  hash_ann_symbol                          :string(255)
#  introduced_distribution_ary_en           :string           is an Array
#  introduced_distribution_ary_es           :string           is an Array
#  introduced_distribution_ary_fr           :string           is an Array
#  introduced_uncertain_distribution_ary_en :string           is an Array
#  introduced_uncertain_distribution_ary_es :string           is an Array
#  introduced_uncertain_distribution_ary_fr :string           is an Array
#  kingdom_name                             :string(255)
#  kingdom_position                         :integer
#  name_status                              :string(255)
#  native_distribution_ary_en               :string           is an Array
#  native_distribution_ary_es               :string           is an Array
#  native_distribution_ary_fr               :string           is an Array
#  order_name                               :string(255)
#  phylum_name                              :string(255)
#  rank_display_name_en                     :string(255)
#  rank_display_name_es                     :string(255)
#  rank_display_name_fr                     :string(255)
#  rank_name                                :string(255)
#  reintroduced_distribution_ary_en         :string           is an Array
#  reintroduced_distribution_ary_es         :string           is an Array
#  reintroduced_distribution_ary_fr         :string           is an Array
#  show_in_species_plus                     :boolean
#  spanish_names_ary                        :string           is an Array
#  species_listings_ids                     :integer          is an Array
#  species_listings_ids_aggregated          :integer          is an Array
#  species_name                             :string(255)
#  spp                                      :boolean
#  subfamily_name                           :string(255)
#  subspecies_name                          :string(255)
#  synonyms_ary                             :string           is an Array
#  synonyms_author_years_ary                :string           is an Array
#  taxon_concept_id_com                     :integer
#  taxon_concept_id_syn                     :integer
#  taxonomic_position                       :string(255)
#  taxonomy_is_cites_eu                     :boolean
#  uncertain_distribution_ary_en            :string           is an Array
#  uncertain_distribution_ary_es            :string           is an Array
#  uncertain_distribution_ary_fr            :string           is an Array
#  created_at                               :datetime
#  updated_at                               :datetime
#  class_id                                 :integer
#  family_id                                :integer
#  genus_id                                 :integer
#  kingdom_id                               :integer
#  order_id                                 :integer
#  parent_id                                :integer
#  phylum_id                                :integer
#  rank_id                                  :integer
#  species_id                               :integer
#  subfamily_id                             :integer
#  subspecies_id                            :integer
#  taxonomy_id                              :integer
#
# Indexes
#
#  taxon_concepts_mview_tmp_cites_show_name_status_cites_listi_idx  (cites_show,name_status,cites_listing_original,taxonomy_is_cites_eu,rank_name)
#  taxon_concepts_mview_tmp_cms_show_name_status_cms_listing_o_idx  (cms_show,name_status,cms_listing_original,taxonomy_is_cites_eu,rank_name)
#  taxon_concepts_mview_tmp_countries_ids_ary_idx1                  (countries_ids_ary) USING gin
#  taxon_concepts_mview_tmp_eu_show_name_status_eu_listing_ori_idx  (eu_show,name_status,eu_listing_original,taxonomy_is_cites_eu,rank_name)
#  taxon_concepts_mview_tmp_id_idx                                  (id)
#  taxon_concepts_mview_tmp_parent_id_idx                           (parent_id)
#  taxon_concepts_mview_tmp_taxonomy_is_cites_eu_cites_listed__idx  (taxonomy_is_cites_eu,cites_listed,kingdom_position)
#

class MTaxonConcept < ApplicationRecord
  extend Mobility
  self.table_name = :taxon_concepts_mview
  self.primary_key = :id

  belongs_to :taxon_concept, foreign_key: :id, optional: true
  has_many :cites_listing_changes, foreign_key: :taxon_concept_id, class_name: 'MCitesListingChange'
  has_many :historic_cites_listing_changes_for_downloads, -> {
    where(
      show_in_downloads: true
    ).order(
      Arel.sql(
        <<-SQL
          effective_at,
          CASE
          WHEN change_type_name = 'ADDITION' THEN 0
          WHEN change_type_name = 'RESERVATION' THEN 1
          WHEN change_type_name = 'RESERVATION_WITHDRAWAL' THEN 2
          WHEN change_type_name = 'DELETION' THEN 3
          END
        SQL
      )
    )
  }, foreign_key: :taxon_concept_id,
    class_name: 'MCitesListingChange'
  has_many :current_cites_additions, -> { where(is_current: true, change_type_name: ChangeType::ADDITION).order('effective_at DESC, species_listing_name ASC') },
    foreign_key: :taxon_concept_id,
    class_name: 'MCitesListingChange'
  has_many :current_cms_additions, -> { where(is_current: true, change_type_name: ChangeType::ADDITION).order('effective_at DESC, species_listing_name ASC') },
    foreign_key: :taxon_concept_id,
    class_name: 'MCmsListingChange'
  has_many :cites_processes
  scope :by_cites_eu_taxonomy, -> { where(taxonomy_is_cites_eu: true) }
  scope :by_cms_taxonomy, -> { where(taxonomy_is_cites_eu: false) }

  scope :without_non_accepted, -> { where(name_status: [ 'A', 'H' ]) }

  scope :without_hidden, -> { where("#{table_name}.cites_show = 't'") }

  scope :by_name, lambda { |name, match_options|
    MTaxonConceptFilterByScientificNameWithDescendants.new(
      self, name, match_options
    ).relation
  }

  scope :by_scientific_name, lambda { |scientific_name|
    MTaxonConceptFilterByScientificNameWithDescendants.new(
      self,
      scientific_name,
      { synonyms: true, common_names: true, subspecies: false }
    ).relation
  }

  scope :at_level_of_listing, -> { where(cites_listed: 't') }

  scope :taxonomic_layout, -> { order('taxonomic_position') }
  scope :alphabetical_layout, -> { order([ 'kingdom_position', 'full_name' ]) }
  translates :rank_display_name,
    :all_distribution_ary, :native_distribution_ary,
    :introduced_distribution_ary, :introduced_uncertain_distribution_ary,
    :reintroduced_distribution_ary, :extinct_distribution_ary,
    :extinct_uncertain_distribution_ary, :uncertain_distribution_ary

  # leftover from old Checklist code, this field is used in returned json
  def current_listing
    cites_listing
  end

  def self.descendants_ids(taxon_concept)
    query = <<-SQL
    WITH RECURSIVE descendents AS (
      SELECT id, rank_id, full_name
      FROM #{self.table_name}
      WHERE parent_id = #{taxon_concept.to_i}
      UNION ALL
      SELECT taxon_concepts.id, taxon_concepts.rank_id, taxon_concepts.full_name
      FROM #{self.table_name} taxon_concepts
      JOIN descendents h ON h.id = taxon_concepts.parent_id
    )
    SELECT id FROM descendents
    ORDER BY rank_id ASC, full_name
    SQL
    res = ApplicationRecord.connection.execute(query)
    res.ntuples.zero? ? [ taxon_concept.to_i ] : res.map(&:values).flatten << taxon_concept.to_i
  end

  def spp
    if [ 'GENUS', 'FAMILY', 'SUBFAMILY', 'ORDER' ].include?(rank_name)
      'spp.' unless name_status == 'H' # Hybrids are not species groups
    else
      nil
    end
  end

  [ 'English', 'Spanish', 'French' ].each do |lng|
    define_method("#{lng.downcase}_names") do
      sym = :"#{lng.downcase}_names_ary"
      db_ary_to_array(sym)
    end
  end

  def synonyms
    db_ary_to_array :synonyms_ary
  end

  def synonyms_author_years
    db_ary_to_array :synonyms_author_years_ary
  end

  def synonyms_with_authors
    synonyms.each_with_index.map { |syn, idx| "#{syn} #{synonyms_author_years[idx]}" }
  end

  def db_ary_to_array(ary)
    if respond_to?(ary)
      attr = send(ary)
      return [] unless attr.present?
      attr.map(&:to_s)
    else
      []
    end
  end

  def countries_ids
    if respond_to?(:countries_ids_ary) && countries_ids_ary?
      countries_ids_ary || []
    elsif respond_to? :tc_countries_ids_ary
      tc_countries_ids_ary || []
    else
      []
    end
  end

  def countries_iso_codes
    all_distribution_iso_codes
  end

  def countries_full_names
    all_distribution
  end

  def all_distribution
    all_distribution_ary || []
  end

  def all_distribution_iso_codes
    all_distribution_iso_codes_ary || []
  end

  def native_distribution
    native_distribution_ary || []
  end

  def introduced_distribution
    introduced_distribution_ary || []
  end

  def introduced_uncertain_distribution
    introduced_uncertain_distribution_ary || []
  end

  def reintroduced_distribution
    reintroduced_distribution_ary || []
  end

  def extinct_distribution
    extinct_distribution_ary || []
  end

  def extinct_uncertain_distribution
    extinct_uncertain_distribution_ary || []
  end

  def uncertain_distribution
    uncertain_distribution_ary || []
  end

  def recently_changed
    (cites_listing_updated_at ? cites_listing_updated_at > 8.years.ago : false)
  end

  # the methods below are for checklist downloads only and a bad idea as well

  [ 'en', 'es', 'fr' ].each do |lng|
    [ "hash_full_note_#{lng.downcase}", "full_note_#{lng.downcase}", "short_note_#{lng.downcase}" ].each do |method_name|
      define_method(method_name) do
        current_cites_additions.map do |lc|
          note = lc.send(method_name) || ''
          note && ("Appendix #{lc.species_listing_name}:" + (note || '') + (" #{lc.nomenclature_note}" || ''))
        end.join("\n")
      end
    end
  end

  # returns the ids of parties associated with current listing changes
  # used only for CITES Checklist atm, therefore a designation filter is applied
  def current_parties_ids
    current_cites_additions.map(&:party_id).compact.uniq
  end

  def current_parties_iso_codes
    CountryDictionary.instance.get_iso_codes_by_ids(current_parties_ids).compact
  end

  def current_parties_full_names
    CountryDictionary.instance.get_names_by_ids(current_parties_ids).compact
  end
end
