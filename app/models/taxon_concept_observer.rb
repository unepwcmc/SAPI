class TaxonConceptObserver < ActiveRecord::Observer

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
    if ['A', 'N'].include? taxon_concept.name_status
      tcd = TaxonConceptData.new(taxon_concept)
      data = tcd.to_h
      taxon_concept.update_column(:data, ActiveRecord::Coders::Hstore.dump(data))
      taxon_concept.data = data
    end
    if taxon_concept.name_status == 'S'
      taxon_concept.rebuild_relationships(taxon_concept.accepted_names_ids)
    end
    if taxon_concept.name_status == 'T'
      taxon_concept.rebuild_relationships(taxon_concept.accepted_names_for_trade_name_ids)
    end
    if taxon_concept.name_status == 'H'
      taxon_concept.rebuild_relationships(taxon_concept.hybrid_parents_ids)
    end
    DownloadsCacheCleanupWorker.perform_async(:taxon_concepts)
  end

  def after_destroy(taxon_concept)
    DownloadsCacheCleanupWorker.perform_async(:taxon_concepts)
  end

end
