class EventActivationWorker
  include Sidekiq::Worker
  def perform(event_id)
    Event.transaction do
      ActiveRecord::Base.connection.execute <<-SQL
        WITH non_current_events AS (
          UPDATE events SET is_current = FALSE
          WHERE type IN (
            SELECT type FROM events WHERE id = #{event_id}
          ) AND id != #{event_id}
          RETURNING id
        )
        UPDATE listing_changes
        SET is_current = FALSE
        FROM non_current_events
        WHERE non_current_events.id = listing_changes.event_id;

        UPDATE listing_changes
        SET is_current = TRUE
        WHERE event_id = #{event_id}
      SQL
    end
  end
end