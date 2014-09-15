class EuRegulationObserver < ActiveRecord::Observer

  def after_create(eu_regulation)
    unless eu_regulation.listing_changes_event_id.blank?
      EventListingChangesCopyWorker.perform_async(
        eu_regulation.listing_changes_event_id.to_i, eu_regulation.id
      )
    end
  end

  def after_activate(eu_regulation)
    EuRegulationActivationWorker.perform_async(eu_regulation.id, true)
  end

  def after_deactivate(eu_regulation)
    EuRegulationActivationWorker.perform_async(eu_regulation.id, false)
  end

end
