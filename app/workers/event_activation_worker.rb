class EventActivationWorker
  include Sidekiq::Worker
  def perform(event_id)
    Event.transaction do
      event = Event.find(event_id)
      previously_current_events = event.designation.events.
        where(:is_current => true).where("id != #{event.id}")
      previously_current_events.update_all(:is_current => false)
      previously_current_events.each do |e|
        e.listing_changes.update_all(:is_current => false)
      end
      event.listing_changes.update_all(:is_current => true)
    end
  end
end