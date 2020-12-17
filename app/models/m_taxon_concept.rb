# == Schema Information
#
# Table name: taxon_concepts_mview
#
#  id                                       :integer          primary key
#  parent_id                                :integer
#  taxonomy_id                              :integer
#  taxonomy_is_cites_eu                     :boolean
#  full_name                                :string(255)
#  name_status                              :string(255)
#  rank_id                                  :integer
#  rank_name                                :string(255)
#  rank_display_name_en                     :string(255)
#  rank_display_name_es                     :string(255)
#  rank_display_name_fr                     :string(255)
#  spp                                      :boolean
#  cites_accepted                           :boolean
#  kingdom_position                         :integer
#  taxonomic_position                       :string(255)
#  kingdom_name                             :string(255)
#  phylum_name                              :string(255)
#  class_name                               :string(255)
#  order_name                               :string(255)
#  family_name                              :string(255)
#  subfamily_name                           :string(255)
#  genus_name                               :string(255)
#  species_name                             :string(255)
#  subspecies_name                          :string(255)
#  kingdom_id                               :integer
#  phylum_id                                :integer
#  class_id                                 :integer
#  order_id                                 :integer
#  family_id                                :integer
#  subfamily_id                             :integer
#  genus_id                                 :integer
#  species_id                               :integer
#  subspecies_id                            :integer
#  cites_i                                  :boolean
#  cites_ii                                 :boolean
#  cites_iii                                :boolean
#  cites_listed                             :boolean
#  cites_listed_descendants                 :boolean
#  cites_show                               :boolean
#  cites_status                             :string(255)
#  cites_listing_original                   :string(255)
#  cites_listing                            :string(255)
#  cites_listing_updated_at                 :datetime
#  ann_symbol                               :string(255)
#  hash_ann_symbol                          :string(255)
#  hash_ann_parent_symbol                   :string(255)
#  eu_listed                                :boolean
#  eu_show                                  :boolean
#  eu_status                                :string(255)
#  eu_listing_original                      :string(255)
#  eu_listing                               :string(255)
#  eu_listing_updated_at                    :datetime
#  cms_listed                               :boolean
#  cms_show                                 :boolean
#  cms_status                               :string(255)
#  cms_listing_original                     :string(255)
#  cms_listing                              :string(255)
#  cms_listing_updated_at                   :datetime
#  species_listings_ids                     :string
#  species_listings_ids_aggregated          :string
#  author_year                              :string(255)
#  created_at                               :datetime
#  updated_at                               :datetime
#  dependents_updated_at                    :datetime
#  taxon_concept_id_com                     :integer
#  english_names_ary                        :string
#  spanish_names_ary                        :string
#  french_names_ary                         :string
#  taxon_concept_id_syn                     :integer
#  synonyms_ary                             :string
#  synonyms_author_years_ary                :string
#  countries_ids_ary                        :string
#  all_distribution_iso_codes_ary           :string
#  all_distribution_ary_en                  :string
#  native_distribution_ary_en               :string
#  introduced_distribution_ary_en           :string
#  introduced_uncertain_distribution_ary_en :string
#  reintroduced_distribution_ary_en         :string
#  extinct_distribution_ary_en              :string
#  extinct_uncertain_distribution_ary_en    :string
#  uncertain_distribution_ary_en            :string
#  all_distribution_ary_es                  :string
#  native_distribution_ary_es               :string
#  introduced_distribution_ary_es           :string
#  introduced_uncertain_distribution_ary_es :string
#  reintroduced_distribution_ary_es         :string
#  extinct_distribution_ary_es              :string
#  extinct_uncertain_distribution_ary_es    :string
#  uncertain_distribution_ary_es            :string
#  all_distribution_ary_fr                  :string
#  native_distribution_ary_fr               :string
#  introduced_distribution_ary_fr           :string
#  introduced_uncertain_distribution_ary_fr :string
#  reintroduced_distribution_ary_fr         :string
#  extinct_distribution_ary_fr              :string
#  extinct_uncertain_distribution_ary_fr    :string
#  uncertain_distribution_ary_fr            :string
#  show_in_species_plus                     :boolean
#  dirty                                    :boolean
#  expiry                                   :datetime
#

class MTaxonConcept < ActiveRecord::Base
  self.table_name = :taxon_concepts_mview
  self.primary_key = :id

  belongs_to :taxon_concept, :foreign_key => :id
  has_many :cites_listing_changes, :foreign_key => :taxon_concept_id, :class_name => MCitesListingChange
  has_many :historic_cites_listing_changes_for_downloads, -> { where(show_in_downloads: true).order(
    <<-SQL
      effective_at,
      CASE
      WHEN change_type_name = 'ADDITION' THEN 0
      WHEN change_type_name = 'RESERVATION' THEN 1
      WHEN change_type_name = 'RESERVATION_WITHDRAWAL' THEN 2
      WHEN change_type_name = 'DELETION' THEN 3
      END
    SQL
    ) }, :foreign_key => :taxon_concept_id,
    :class_name => MCitesListingChange
  has_many :current_cites_additions, -> { where(is_current: true, change_type_name: ChangeType::ADDITION).order('effective_at DESC, species_listing_name ASC') },
    :foreign_key => :taxon_concept_id,
    :class_name => MCitesListingChange
  has_many :current_cms_additions, -> { where(is_current: true, change_type_name: ChangeType::ADDITION).order('effective_at DESC, species_listing_name ASC') },
    :foreign_key => :taxon_concept_id,
    :class_name => MCmsListingChange
  scope :by_cites_eu_taxonomy, -> { where(:taxonomy_is_cites_eu => true) }
  scope :by_cms_taxonomy, -> { where(:taxonomy_is_cites_eu => false) }

  scope :without_non_accepted, -> { where(:name_status => ['A', 'H']) }

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
      { :synonyms => true, :common_names => true, :subspecies => false }
    ).relation
  }

  scope :at_level_of_listing, -> { where(:cites_listed => 't') }

  scope :taxonomic_layout, -> { order('taxonomic_position') }
  scope :alphabetical_layout, -> { order(['kingdom_position', 'full_name']) }
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
    res = ActiveRecord::Base.connection.execute(query)
    res.ntuples.zero? ? [taxon_concept.to_i] : res.map(&:values).flatten << taxon_concept.to_i
  end

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
    return (cites_listing_updated_at ? cites_listing_updated_at > 8.year.ago : false)
  end

  # the methods below are for checklist downloads only and a bad idea as well

  ['en', 'es', 'fr'].each do |lng|
    ["hash_full_note_#{lng.downcase}", "full_note_#{lng.downcase}", "short_note_#{lng.downcase}"].each do |method_name|
      define_method(method_name) do
        current_cites_additions.map do |lc|
          note = lc.send(method_name) || ''
          note && "Appendix #{lc.species_listing_name}:" + (note || '') + (" #{lc.nomenclature_note}" || '')
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
