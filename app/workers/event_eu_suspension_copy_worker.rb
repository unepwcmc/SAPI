class EventEuSuspensionCopyWorker
  include Sidekiq::Worker
  def perform(from_event_id, to_event_id)
    ActiveRecord::Base.connection.execute <<-SQL
      SELECT * FROM copy_eu_suspensions_across_events(
        #{from_event_id},
        #{to_event_id}
      )
    SQL
  end
end