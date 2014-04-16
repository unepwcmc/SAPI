class DestroyObserver < ActiveRecord::Observer
  observe :taxonomy, :rank, :taxon_concept, :designation, :change_type,
    :species_listing, :geo_entity, :language, :term, :unit, :source, :purpose,
    :user, :cites_suspension_notification, :cites_cop, :eu_regulation,
    :eu_decision_type, :reference, :instrument, :eu_suspension_regulation

  def before_destroy(model)
    unless model.can_be_deleted?
      if model.respond_to?(:dependent_objects)
        model.errors.add(:base, "not allowed (dependent objects present: #{model.dependent_objects.join(', ')})")
      else
        model.errors.add(:base, "not allowed (dependent objects present)")
      end
      return false
    end
  end
end
