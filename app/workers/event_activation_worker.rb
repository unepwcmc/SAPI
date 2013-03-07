class EventActivationWorker
  include Sidekiq::Worker
  def perform(event_id)
    Event.transaction do
      ActiveRecord::Base.connection.execute <<-SQL
        WITH non_current_events AS (
          WITH designation AS (
            SELECT DISTINCT designation_id AS id
            FROM events WHERE id = #{event_id}
          )
          UPDATE events SET is_current = FALSE
          FROM designation
          WHERE designation.id = events.designation_id
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