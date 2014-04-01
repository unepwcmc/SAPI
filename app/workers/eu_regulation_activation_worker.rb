class EuRegulationActivationWorker
  include Sidekiq::Worker
  sidekiq_options :queue => :admin, :retry => false, :backtrace => 50

  def perform(event_id, state)
    ActiveRecord::Base.connection.execute <<-SQL
      UPDATE listing_changes
      SET is_current = #{state}
      WHERE event_id = #{event_id}
    SQL
  end
end
