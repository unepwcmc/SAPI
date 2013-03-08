class DestroyObserver < ActiveRecord::Observer
  observe :taxonomy, :rank, :taxon_concept, :designation, :event, :change_type,
    :species_listing, :geo_entity, :language, :trade_code, :user
  def before_destroy(model)
    unless model.can_be_deleted?
      model.errors.add(:base, "not allowed (dependent objects present)")
      return false
    end
  end
end