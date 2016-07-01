class Checklist::TaxonConceptSerializer < ActiveModel::Serializer
  attributes :id, :full_name, :rank_name, :cites_accepted,
    :subspecies_name, :species_name, :genus_name, :family_name, :order_name,
    :class_name, :phylum_name, :kingdom_name, :hash_ann_symbol,
    :countries_ids, :ancestors_path, :recently_changed,
    :current_parties_ids, :current_listing,
    :author_year, :english_names, :spanish_names, :french_names,
    :synonyms_with_authors, :synonyms, :ancestors_ids, :ancestors_path, :item_type

  has_many :current_cites_additions, :serializer => Checklist::ListingChangeSerializer,
    :key => :current_additions

  def id
    if object.is_a? Checklist::HigherTaxaItem
      object.id + 1000000 # unless ids differ, Ember will create a single object
    else
      object.id
    end
  end

  def item_type
    return 'HigherTaxa' if object.is_a? Checklist::HigherTaxaItem
    'TaxonConcept'
  end

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

  def include_ancestors_ids?
    object.is_a? Checklist::HigherTaxaItem
  end

  def include_ancestors_path?
    object.is_a? Checklist::HigherTaxaItem
  end

end
