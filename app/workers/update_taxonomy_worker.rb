class UpdateTaxonomyWorker
  include Sidekiq::Worker

  def perform
    Rails.logger.debug 'Procedure: taxonomy'
    ApplicationRecord.connection.execute(
      'SELECT * FROM rebuild_taxonomy()'
    )

    changed_cnt = TaxonConcept.where('touched_at IS NOT NULL AND touched_at > updated_at').count

    if changed_cnt > 0
      # increment cache iterators if anything changed
      Species::Search.increment_cache_iterator
      Species::TaxonConceptPrefixMatcher.increment_cache_iterator
      Checklist::Checklist.increment_cache_iterator

      TaxonConcept.where(
        'touched_at IS NOT NULL AND touched_at > updated_at'
      ).update_all(
        'updated_at = touched_at',
      )
    end
  end
end
