class DestroyObserver < ActiveRecord::Observer
  observe :taxonomy, :rank, :taxon_concept, :designation, :change_type,
    :species_listing, :geo_entity, :language, :trade_code, :user,
    :cites_suspension_notification, :cites_cop, :eu_regulation,
    :eu_decision_type, :reference
  def before_destroy(model)
    unless model.can_be_deleted?
      model.errors.add(:base, "not allowed (dependent objects present)")
      return false
    end
  end
end
