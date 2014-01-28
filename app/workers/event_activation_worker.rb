class EventActivationWorker
  include Sidekiq::Worker
  def perform(event_id, state)
    Event.transaction do
      ActiveRecord::Base.connection.execute <<-SQL
        UPDATE listing_changes
        SET is_current = #{state}
        WHERE event_id = #{event_id}
      SQL
    end
  end
end
