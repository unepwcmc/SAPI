class EuSuspensionRegulationActivationWorker
  include Sidekiq::Worker
  def perform(event_id, state)
    Event.transaction do
      ActiveRecord::Base.connection.execute <<-SQL
        UPDATE eu_decisions
        SET is_current = #{state}
        WHERE start_event_id = #{event_id} AND
         type = 'EuSuspension'
      SQL
    end
  end
end
