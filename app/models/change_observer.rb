class ChangeObserver < ActiveRecord::Observer
  observe :taxon_common, :distribution, :eu_decision,
    :listing_change, :taxon_concept_reference,
    :taxon_instrument, :taxon_relationship, :cites_suspension, :quota,
    :geo_entity, :language

  def after_save(model)
    clear_cache model

    # For models that are not directly related to taxon concepts
    # but for which is anyway preferable for the changes to be reflacted
    # immedtiately on the public interface, clear the entire serializer cache.
    # Models like GeoEntity and Language are not directly linked to TaxonConcept,
    # so bumping the dependents_updated_at timestamp seems a bit confusing.
    # Also there's currently no easy way to tell who updated those objects.
    # It's quite rare that updates to those objects will occur,
    # so there shouldn't be no harm in clearning the entire serializer cache.
    unless model.respond_to?(:taxon_concept)
      clear_show_tc_serializer_cache
      return
    end

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
    if model.respond_to?(:taxon_concept) && model.taxon_concept && model.can_be_deleted?
      # currently no easy means to tell who deleted the dependent object
      bump_dependents_timestamp(model.taxon_concept, nil)
    end
  end

  protected

  def clear_cache(model)
    return unless model.respond_to?(:taxon_concept)
    DownloadsCacheCleanupWorker.perform_async(model.class.to_s.tableize.to_sym)
  end

  def clear_show_tc_serializer_cache
    Rails.cache.delete_matched('*ShowTaxonConceptSerializer*')
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
