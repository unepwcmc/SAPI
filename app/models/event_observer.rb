class EventObserver < ActiveRecord::Observer
  def after_create(event)
    unless event.listing_changes_event_id.blank?
      EventListingChangesCopyWorker.perform_async(
        event.listing_changes_event_id.to_i, event.id
      )
    end
  end

  def after_activate(event)
    EventActivationWorker.perform_async(event.id)
  end

end