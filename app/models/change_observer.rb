class ChangeObserver < ActiveRecord::Observer
  observe :taxon_common, :distribution, :eu_decision,
    :listing_change, :taxon_concept_reference,
    :taxon_instrument, :taxon_relationship, :trade_restriction

  def after_save(model)
    model.taxon_concept.
      update_column(:dependents_updated_at, Time.now)
  end

  def before_destroy(model)
    if model.can_be_deleted?
      model.taxon_concept.
        update_column(:dependents_updated_at, Time.now)
    end
  end
end
