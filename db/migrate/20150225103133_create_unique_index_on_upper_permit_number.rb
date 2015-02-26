class CreateUniqueIndexOnUpperPermitNumber < ActiveRecord::Migration
  def up
    # before creating a unique index on UPPER(number) need to deal with duplicates
    # all detected duplicates will need to be removed, but first the shipments
    # need to be updated
    execute <<-SQL
    WITH duplicated_permit_ids AS (
      SELECT min_id, dup_id FROM (
        SELECT min_id, UNNEST(duplicated_ids) AS dup_id FROM (
          SELECT MIN(id) AS min_id, ARRAY_AGG_NOTNULL(id) AS duplicated_ids, COUNT(*)
          FROM trade_permits
          GROUP BY UPPER(number)
          HAVING COUNT(*) > 1
        ) s
      ) ss
      WHERE ss.dup_id != ss.min_id
    ), updated_shipments_with_import_permits AS (
      UPDATE trade_shipments SET import_permits_ids = ARRAY_REPLACE(import_permits_ids, dup_id, min_id)
      FROM duplicated_permit_ids
      WHERE import_permits_ids @> ARRAY[duplicated_permit_ids.dup_id]
    ), updated_shipments_with_export_permits AS (
      UPDATE trade_shipments SET export_permits_ids = ARRAY_REPLACE(export_permits_ids, dup_id, min_id)
      FROM duplicated_permit_ids
      WHERE export_permits_ids @> ARRAY[duplicated_permit_ids.dup_id]
    ), updated_shipments_with_origin_permits AS (
      UPDATE trade_shipments SET origin_permits_ids = ARRAY_REPLACE(origin_permits_ids, dup_id, min_id)
      FROM duplicated_permit_ids
      WHERE origin_permits_ids @> ARRAY[duplicated_permit_ids.dup_id]
    )
    DELETE FROM trade_permits
    USING duplicated_permit_ids
    WHERE trade_permits.id = dup_id;
    SQL
    execute 'DROP INDEX trade_permits_number_idx'
    execute 'CREATE UNIQUE INDEX trade_permits_number_idx ON trade_permits USING btree (UPPER(number) varchar_pattern_ops)'
  end

  def down
    execute 'DROP INDEX trade_permits_number_idx'
    execute 'CREATE UNIQUE INDEX trade_permits_number_idx ON trade_permits USING btree (number)'
  end
end
