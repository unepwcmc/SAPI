##
# In addition to deleting data, some consideration should be given to database
# maintenance:
#
# ANALYSE calculates summary stats about a table and its columns. These stats
# are used in query planning, so bad stats
#
# REINDEX is called because some large tables have gigabytes locked away in
# indexes, and REINDEX is the quickest way to free up that space.
#
# VACUUM can only reclaim space from dead tuples so often is not worth it.
# Furthermore space it reclaims is still reserved for the table, so is not
# released by the file system - for that VACUUM FULL is required, which requires
# a full table rewrite, which takes up additional disk space which may not be
# free.

namespace :db do
  desc 'Deletes historic and sensitive data, runs cleanup of temporary tables and rebuilds'
  task trim: [
    :environment,
    'db:trim_ahoy',
    'db:trim_api_requests',
    'db:common_names:cleanup',
    'db:taxon_names:cleanup',
    'db:trim_trade',
    'db:trim_listing_changes',
    'db:trim_trade_restrictions',
    'db:trim_eu_decisions',
    'db:trim_users',
    'import:drop_import_tables',
    'db:migrate:rebuild',
    'db:drop_temporary_tables',
    'db:vacuum_full'
  ]

  ##
  # Drop all tables of the form /^trade_sandbox_\d+$/
  # and their associated views and indexes
  task trim_trade_sandboxes: :environment do
    sandbox_group_count = 50

    sandbox_query =
      <<-SQL.squish
        SELECT count(*) FROM information_schema.tables
        WHERE table_name LIKE 'trade_sandbox%'
          AND table_name != 'trade_sandbox_template'
          AND table_type != 'VIEW'
      SQL

    sandbox_count =
      ApplicationRecord.connection.execute(
        sandbox_query
      )[0]['count'].to_i

    (
      sandbox_count.to_f / sandbox_group_count
    ).ceil.times do
      ApplicationRecord.connection.execute <<-SQL.squish
        DO $do$
          DECLARE
            current_table_name TEXT;
          BEGIN
            FOR current_table_name
            IN #{sandbox_query}
            LIMIT #{sandbox_group_count}
            LOOP
              EXECUTE 'DROP TABLE ' || current_table_name || ' CASCADE';
            END LOOP;
            RETURN;
          END;
        $do$;
      SQL
    end
  end

  task trim_trade: :environment do
    year = Date.today.year - 5

    puts "Deleting shipments prior to #{year}"
    ApplicationRecord.connection.execute <<-SQL.squish
      DELETE FROM trade_shipments WHERE year <= #{year}
    SQL

    ApplicationRecord.connection.execute 'ANALYSE trade_shipments;'
    ApplicationRecord.connection.execute 'REINDEX TABLE trade_shipments;'

    puts 'Clearing permits'
    # Note: where clause don't make unnecessary writes to rows
    ApplicationRecord.connection.execute <<-SQL.squish
      UPDATE trade_shipments SET
        import_permit_number = NULL,
        export_permit_number = NULL,
        origin_permit_number = NULL,
        import_permits_ids = '{}'::INT[],
        export_permits_ids = '{}'::INT[],
        origin_permits_ids = '{}'::INT[],
        trade_annual_report_upload_id = NULL,
        sandbox_id = NULL
      WHERE origin_permit_number IS NOT NULL
        OR export_permit_number IS NOT NULL
        OR origin_permit_number IS NOT NULL
        OR trade_annual_report_upload_id IS NOT NULL
        OR sandbox_id IS NOT NULL
      ;
    SQL

    puts 'Truncating permits'
    ApplicationRecord.connection.execute 'TRUNCATE trade_permits'
    ApplicationRecord.connection.execute 'REINDEX TABLE trade_permits'

    ##
    # drop_trade_sandboxes() does not work when there are many sandboxes
    #
    #   puts 'Dropping sandboxes'
    #   ApplicationRecord.connection.execute 'SELECT * FROM drop_trade_sandboxes()'

    puts "Deleting annual reports uploaded prior to #{year}"
    ApplicationRecord.connection.execute <<-SQL.squish
      DELETE FROM trade_annual_report_uploads
      WHERE updated_at <= '#{year}-01-01';
    SQL

    ApplicationRecord.connection.execute 'ANALYSE trade_annual_report_uploads;'
    ApplicationRecord.connection.execute 'REINDEX TABLE trade_annual_report_uploads;'
  end

  task trim_listing_changes: :environment do
    sql = <<-SQL.squish
      WITH non_current_listing_changes AS (
        SELECT * FROM listing_changes
        WHERE NOT is_current
      ), exceptions AS (
        SELECT lc.* FROM non_current_listing_changes nc_lc
        JOIN listing_changes lc
        ON lc.parent_id = nc_lc.id
      ), listing_changes_to_delete AS (
        SELECT * FROM non_current_listing_changes
        EXCEPT
        SELECT * FROM exceptions
      ), deleted_listing_distributions AS (
        DELETE FROM listing_distributions
        USING listing_changes_to_delete lc
        WHERE lc.id = listing_distributions.listing_change_id
      ), updated_original_id AS (
        UPDATE listing_changes
        SET original_id = NULL
        FROM listing_changes_to_delete
        WHERE listing_changes.original_id = listing_changes_to_delete.id
      ), updated_parent_id AS (
        UPDATE listing_changes
        SET parent_id = NULL
        FROM listing_changes_to_delete
        WHERE listing_changes.parent_id = listing_changes_to_delete.id
      )
      DELETE FROM listing_changes
      USING listing_changes_to_delete lc
      WHERE lc.id = listing_changes.id;
    SQL

    puts 'Deleting old listing changes'
    ApplicationRecord.connection.execute sql
    ApplicationRecord.connection.execute 'ANALYSE listing_changes;'
    ApplicationRecord.connection.execute 'REINDEX TABLE listing_changes;'
  end

  task trim_trade_restrictions: :environment do
    sql = <<-SQL.squish
      WITH trade_restrictions_to_delete AS (
        SELECT * FROM trade_restrictions
        WHERE NOT is_current
      ), deleted_cites_suspension_confirmations AS (
        DELETE FROM cites_suspension_confirmations
        USING trade_restrictions_to_delete
        WHERE cites_suspension_confirmations.cites_suspension_id = trade_restrictions_to_delete.id
      ), deleted_restriction_purposes AS (
        DELETE FROM trade_restriction_purposes
        USING trade_restrictions_to_delete
        WHERE trade_restriction_purposes.trade_restriction_id = trade_restrictions_to_delete.id
      ), deleted_restriction_sources AS (
        DELETE FROM trade_restriction_sources
        USING trade_restrictions_to_delete
        WHERE trade_restriction_sources.trade_restriction_id = trade_restrictions_to_delete.id
      ), deleted_restriction_terms AS (
        DELETE FROM trade_restriction_terms
        USING trade_restrictions_to_delete
        WHERE trade_restriction_terms.trade_restriction_id = trade_restrictions_to_delete.id
      ), updated_original_id AS (
        UPDATE trade_restrictions
        SET original_id = NULL
        FROM trade_restrictions_to_delete
        WHERE trade_restrictions.original_id = trade_restrictions_to_delete.id
      )
      DELETE FROM trade_restrictions
      USING trade_restrictions_to_delete tr
      WHERE tr.id = trade_restrictions.id;
    SQL

    puts 'Deleting old trade restrictions'
    ApplicationRecord.connection.execute sql
    ApplicationRecord.connection.execute 'ANALYSE trade_restrictions;'
    ApplicationRecord.connection.execute 'REINDEX TABLE trade_restrictions;'
  end

  task trim_eu_decisions: :environment do
    puts 'Deleting old EU decisions'
    ApplicationRecord.connection.execute <<-SQL.squish
      DELETE FROM eu_decisions
      WHERE NOT eu_decisions.is_current AND NOT EXISTS (
        SELECT TRUE
        FROM eu_decision_confirmations
        WHERE eu_decision_id = eu_decisions.id
      );
    SQL

    ApplicationRecord.connection.execute 'ANALYSE eu_decisions;'
    ApplicationRecord.connection.execute 'REINDEX TABLE eu_decisions;'
  end

  task trim_users: :environment do
    puts 'Pseudonymising user data'
    ApplicationRecord.connection.execute <<-SQL.squish
      UPDATE "users" u SET
        "name"               = 'User ' || u.id,
        "email"              = 'user.' || u.id || '@test.local',
        "current_sign_in_ip" = '192.168.1.' || (u.id % 256),
        "last_sign_in_ip"    = '192.168.1.' || (u.id % 256)
      WHERE "email" NOT LIKE '%@unep-wcmc.org'
        AND "email" NOT LIKE '%@test.local'
    SQL
  end

  task trim_ahoy: :environment do
    puts 'Removing analytics data'

    ApplicationRecord.connection.execute <<-SQL.squish
      TRUNCATE TABLE ahoy_events;
      REINDEX TABLE ahoy_events;
      TRUNCATE TABLE ahoy_visits;
      REINDEX TABLE ahoy_visits;
    SQL
  end

  task trim_api_requests: :environment do
    cutoff = 2.years.ago.to_date.to_s

    puts "Removing records of API Request data prior to #{cutoff}"

    ApplicationRecord.connection.execute <<-SQL.squish
      DELETE FROM api_requests
        WHERE updated_at <= '#{cutoff}'
      ;
    SQL

    ApplicationRecord.connection.execute 'ANALYSE api_requests;'
    ApplicationRecord.connection.execute 'REINDEX TABLE api_requests;'
  end

  task drop_temporary_tables: :environment do
    puts 'Dropping temporary tables'

    ApplicationRecord.connection.execute 'SELECT * FROM drop_eu_lc_mviews()'
  end

  ##
  # Reclaims space from any table where the number of dead tuples (old versions
  # of rows left over by postgres as a result of updates/deletes) is greater
  # than the number of live tuples. In effect, this means that wherever the size
  # on disk of a table can be reduced by about 50% or more, a full-table rewrite
  # will be performed. This requires a exclusive lock on the entire table.
  task vacuum_full: :environment do
    puts 'Finding tables that need vacuuming'

    vaccumable_sql = <<-SQL.squish
      SELECT
        st.schemaname,
        st.relname,
        n_live_tup,
        n_dead_tup
      FROM pg_catalog.pg_stat_all_tables st
      JOIN pg_catalog.pg_class r
        ON st.relid = r.oid
        AND r.relkind = 't'
      WHERE st.schemaname = 'public'
      AND n_dead_tup > n_live_tup
    SQL

    vacuumables = ApplicationRecord.connection.execute vaccumable_sql

    puts (
      vacuumables.map do |row|
        %Q("#{row['schemaname']}"."#{row['relname']}": #{row['n_dead_tup']} dead, #{row['n_live_tup']} live")
      end.join("\n")
    )

    ApplicationRecord.connection.execute <<-SQL.squish
      DO $do$
        DECLARE
          schemaname TEXT;
          relname TEXT;
        BEGIN
          FOR schemaname, relname IN #{vaccumable_sql}
          LOOP
            EXECUTE format(
              'VACUUM FULL ANALYSE %I$1.%I$2',
              schemaname, relname
            );
          END LOOP;
          RETURN;
        END;
      $do$;
    SQL
  end
end
