class EventListingChangesCopyWorker
  include Sidekiq::Worker
  sidekiq_options :queue => :admin, :retry => false, :backtrace => 50

  def perform(from_event_id, to_event_id)
    ActiveRecord::Base.connection.execute <<-SQL
      SELECT * FROM copy_listing_changes_across_events(
        #{from_event_id},
        #{to_event_id}
      )
    SQL
  end
end
