class EventEuSuspensionCopyWorker
  include Sidekiq::Worker
  sidekiq_options :queue => :admin, :retry => false, :backtrace => 50

  def perform(from_event_id, to_event_id)
    ActiveRecord::Base.connection.execute <<-SQL
      SELECT * FROM copy_eu_suspensions_across_events(
        #{from_event_id.to_i},
        #{to_event_id.to_i}
      )
    SQL
    eu_suspension_regulation = EuSuspensionRegulation.find(to_event_id)
    eu_suspension_regulation.touch_suspensions_and_taxa
  end
end
