class ChangeObserver < ActiveRecord::Observer
  observe :taxon_common, :distribution, :eu_decision,
    :listing_change, :taxon_concept_reference,
    :taxon_instrument, :taxon_relationship, :trade_restriction

  def after_save(model)
    if model.taxon_concept
      model.taxon_concept.
        update_column(:dependents_updated_at, Time.now)
    end
  end

  def before_destroy(model)
    if model.taxon_concept && model.can_be_deleted?
      model.taxon_concept.
        update_column(:dependents_updated_at, Time.now)
    end
  end
end
