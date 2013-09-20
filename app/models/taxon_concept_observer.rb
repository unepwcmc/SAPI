class TaxonConceptObserver < ActiveRecord::Observer

  def after_create(taxon_concept)
    Species::Search.increment_cache_iterator
    Species::TaxonConceptPrefixMatcher.increment_cache_iterator
    Checklist::Checklist.increment_cache_iterator
    Checklist::TaxonConceptPrefixMatcher.increment_cache_iterator
  end

  def after_destroy(taxon_concept)
    Species::Search.increment_cache_iterator
    Species::TaxonConceptPrefixMatcher.increment_cache_iterator
    Checklist::Checklist.increment_cache_iterator
    Checklist::TaxonConceptPrefixMatcher.increment_cache_iterator
  end

  def after_update(taxon_concept)
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

end