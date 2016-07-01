class PermitCleanupWorker
  include Sidekiq::Worker
  sidekiq_options :queue => :admin, :backtrace => 50

  def perform(permits_ids = [])
    return if permits_ids.empty?
    sql = <<-SQL
      WITH unused_permits(id) AS (
        SELECT id FROM trade_permits WHERE id IN (:permits_ids)
        EXCEPT
        SELECT UNNEST(import_permits_ids || export_permits_ids || origin_permits_ids)
        FROM trade_shipments
        WHERE import_permits_ids @> ARRAY[:permits_ids] OR
          export_permits_ids @> ARRAY[:permits_ids] OR
          origin_permits_ids @> ARRAY[:permits_ids]
      )
      DELETE FROM trade_permits
      USING unused_permits
      WHERE trade_permits.id = unused_permits.id
      SQL
    ActiveRecord::Base.connection.execute(
      ActiveRecord::Base.send(:sanitize_sql_array, [
        sql,
        permits_ids: permits_ids.map(&:to_i)
      ])
    )
  end
end
