class TaxonConceptObserver < ActiveRecord::Observer

  #initializes data and full name with values from parent
  def before_create(taxon_concept)
    data = taxon_concept.data || {}
    data['rank_name'] = taxon_concept.rank && taxon_concept.rank.name
    if taxon_concept.parent
      data.merge taxon_concept.parent.data.slice(
        'kingdom_id', 'kingdom_name', 'phylum_id', 'phylum_name', 'class_id',
        'class_name', 'order_id', 'order_name', 'family_id', 'family_name',
        'subfamily_id', 'subfamily_name', 'genus_id', 'genus_name', 'species_id',
        'species_name'
      )
    end
    taxon_concept.data = data
    taxon_concept.full_name = if taxon_concept.rank && taxon_concept.parent &&
      taxon_concept.name_status == 'A'
      rank_name = taxon_concept.rank.name
      parent_full_name = taxon_concept.parent.full_name
      name = taxon_concept.taxon_name && taxon_concept.taxon_name.scientific_name
      if [Rank::SPECIES, Rank::SUBSPECIES].include? rank_name
         "#{parent_full_name} #{name.downcase}"
      elsif rank_name == Rank::VARIETY
        "#{parent_full_name} var. #{name.downcase}"
      else
        name
      end
    else
      taxon_concept.taxon_name && taxon_concept.taxon_name.scientific_name
    end
  end

  def after_create(taxon_concept)
    ensure_species_touched(taxon_concept)
    Species::Search.increment_cache_iterator
    Species::TaxonConceptPrefixMatcher.increment_cache_iterator
    Checklist::Checklist.increment_cache_iterator
  end

  def after_destroy(taxon_concept)
    ensure_species_touched(taxon_concept)
    Species::Search.increment_cache_iterator
    Species::TaxonConceptPrefixMatcher.increment_cache_iterator
    Checklist::Checklist.increment_cache_iterator
  end

  def after_update(taxon_concept)
    ensure_species_touched(taxon_concept)
    if taxon_concept.rank_id_changed? ||
      taxon_concept.taxon_name_id_changed? ||
      taxon_concept.parent_id_changed? ||
      taxon_concept.name_status_changed?
      Species::Search.increment_cache_iterator
      Species::TaxonConceptPrefixMatcher.increment_cache_iterator
      Checklist::Checklist.increment_cache_iterator
    end
  end

  def after_touch(taxon_concept)
    ensure_species_touched(taxon_concept)
  end

  def ensure_species_touched(taxon_concept)
    if taxon_concept.rank && taxon_concept.parent &&
      [Rank::SUBSPECIES, Rank::VARIETY].include?(taxon_concept.rank.name)
      # touch parent if we're a variety or subspecies
      Rails.logger.info "Touch species"
      taxon_concept.parent.touch
    end
  end

  def after_save(taxon_concept)
    DownloadsCache.clear_taxon_concepts_names
  end

  def after_destroy(taxon_concept)
    DownloadsCache.clear_taxon_concepts_names
  end

end
