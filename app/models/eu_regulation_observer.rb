class EuRegulationObserver < ActiveRecord::Observer

  def before_validation(eu_regulation)
    eu = Designation.find_by_name('EU')
    eu_regulation.designation_id = eu && eu.id
  end

  def after_create(eu_regulation)
    unless eu_regulation.listing_changes_event_id.blank?
      EventListingChangesCopyWorker.perform_async(
        eu_regulation.listing_changes_event_id.to_i, eu_regulation.id
      )
    end
  end

  def after_activate(eu_regulation)
    EventActivationWorker.perform_async(eu_regulation.id)
  end

end
