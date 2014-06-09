class DestroyObserver < ActiveRecord::Observer
  observe :taxonomy, :rank, :taxon_concept, :designation, :change_type,
    :species_listing, :geo_entity, :language, :term, :unit, :source, :purpose,
    :user, :cites_suspension_notification, :cites_cop, :eu_regulation,
    :eu_decision_type, :reference, :instrument, :eu_suspension_regulation,
    :preset_tag, :annotation

  def before_destroy(model)
    unless model.can_be_deleted?
      msg = 'not allowed'
      unless model.dependent_objects.empty?
        msg << " (dependent objects present: #{model.dependent_objects.join(', ')})"
      end
      model.errors.add(:base, msg)
      return false
    end
  end
end
