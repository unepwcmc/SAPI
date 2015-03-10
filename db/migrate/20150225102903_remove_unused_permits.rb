class RemoveUnusedPermits < ActiveRecord::Migration
  def up
    execute <<-SQL
      WITH unused_permits(id) AS (
        SELECT id FROM trade_permits
        EXCEPT
        SELECT UNNEST(import_permits_ids || export_permits_ids || origin_permits_ids) FROM trade_shipments
      )
      DELETE FROM trade_permits
      USING unused_permits
      WHERE trade_permits.id = unused_permits.id;
    SQL
  end

  def down
  end
end
