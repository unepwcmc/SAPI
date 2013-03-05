class EventObserver < ActiveRecord::Observer
  def after_create(event)
    unless event.listing_changes_event_id.blank?
      ActiveRecord::Base.connection.execute <<-SQL
        SELECT * FROM copy_listing_changes_across_events(
          #{event.listing_changes_event_id},
          #{event.id}
        )
      SQL
    end
  end
end