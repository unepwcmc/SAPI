class Checklist::IndexTaxonConceptSerializer < ActiveModel::Serializer
  attributes :id,
    :kingdom_name, :phylum_name, :class_name, :order_name, :family_name,
    :genus_name, :species_name, :subspecies_name,
    :full_name, :author_year, :rank_name, :cites_accepted,
    :synonyms_with_authors, :synonyms,
    :english_names, :spanish_names, :french_names,
    :countries_iso_codes, :countries_full_names,
    :current_listing, :current_parties_iso_codes, :current_parties_full_names

  has_many :current_cites_additions,
   :key => :current_listing_changes,
   :serializer => Checklist::IndexListingChangeSerializer

  def include_author_year?
    @options[:authors]
  end

  def include_english_names?
    @options[:english_names]
  end

  def include_spanish_names?
    @options[:spanish_names]
  end

  def include_french_names?
    @options[:french_names]
  end

  def include_synonyms_with_authors?
    @options[:synonyms] && @options[:authors]
  end

  def include_synonyms?
    @options[:synonyms] && !@options[:authors]
  end

end
