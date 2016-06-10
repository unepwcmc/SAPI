class ChangeObserver < ActiveRecord::Observer
  observe :taxon_common, :distribution, :eu_decision,
    :listing_change, :taxon_concept_reference,
    :taxon_instrument, :taxon_relationship, :cites_suspension, :quota

  def after_save(model)
    clear_cache model
    if model.taxon_concept
      bump_dependents_timestamp(model.taxon_concept, model.updated_by_id)
    end
    if model.taxon_concept.nil? && model.taxon_concept_id_was ||
      model.taxon_concept && model.taxon_concept_id_was && model.taxon_concept_id != model.taxon_concept_id_was
      previous_taxon_concept = TaxonConcept.find_by_id(model.taxon_concept_id_was)
      if previous_taxon_concept
        bump_dependents_timestamp(previous_taxon_concept, model.updated_by_id)
      end
    end
  end

  def before_destroy(model)
    clear_cache model
    if model.taxon_concept && model.can_be_deleted?
      # currently no easy means to tell who deleted the dependent object
      bump_dependents_timestamp(model.taxon_concept, nil)
    end
  end

  protected

  def clear_cache(model)
    DownloadsCacheCleanupWorker.perform_async(model.class.to_s.tableize.to_sym)
  end

  def bump_dependents_timestamp(taxon_concept, updated_by_id)
    return unless taxon_concept
    TaxonConcept.where(id: taxon_concept.id).update_all(
      dependents_updated_at: Time.now,
      dependents_updated_by_id: updated_by_id
    )
    DownloadsCacheCleanupWorker.perform_async(:taxon_concepts)
  end
end
