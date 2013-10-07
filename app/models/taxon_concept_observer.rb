class TaxonConceptObserver < ActiveRecord::Observer

  def after_create(taxon_concept)
    ensure_species_touched(taxon_concept)
    Species::Search.increment_cache_iterator
    Species::TaxonConceptPrefixMatcher.increment_cache_iterator
    Checklist::Checklist.increment_cache_iterator
    Checklist::TaxonConceptPrefixMatcher.increment_cache_iterator
  end

  def after_destroy(taxon_concept)
    ensure_species_touched(taxon_concept)
    Species::Search.increment_cache_iterator
    Species::TaxonConceptPrefixMatcher.increment_cache_iterator
    Checklist::Checklist.increment_cache_iterator
    Checklist::TaxonConceptPrefixMatcher.increment_cache_iterator
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
      Checklist::TaxonConceptPrefixMatcher.increment_cache_iterator
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

end