namespace :db do

  desc 'Deletes historic and sensitive data, runs cleanup of temporary tables and rebuilds'
  task :trim => [
    :environment,
    'db:common_names:cleanup',
    'db:taxon_names:cleanup',
    'db:trim_trade',
    'db:trim_listing_changes',
    'db:trim_trade_restrictions',
    'db:trim_eu_decisions',
    'db:trim_users',
    'import:drop_import_tables',
    'db:migrate:rebuild',
    'db:drop_temporary_tables'
  ]

  task :trim_trade => :environment do
    puts 'Deleting old shipments'
    year = Date.today.year - 5
    ActiveRecord::Base.connection.execute "DELETE FROM trade_shipments WHERE year <= #{year}"
    puts 'Clearing permit and annual report data'
    ActiveRecord::Base.connection.execute 'UPDATE trade_shipments SET
        import_permit_number = NULL,
        export_permit_number = NULL,
        origin_permit_number = NULL,
        import_permits_ids = \'{}\'::INT[],
        export_permits_ids = \'{}\'::INT[],
        origin_permits_ids = \'{}\'::INT[],
        trade_annual_report_upload_id = NULL,
        sandbox_id = NULL'
    puts 'Dropping sandboxes'
    ActiveRecord::Base.connection.execute 'SELECT * FROM drop_trade_sandboxes()'
    puts 'Truncating annual reports'
    ActiveRecord::Base.connection.execute 'DELETE FROM trade_annual_report_uploads'
    puts 'Truncating permits'
    ActiveRecord::Base.connection.execute 'TRUNCATE trade_permits'
  end

  task :trim_listing_changes => :environment do
    sql = <<-SQL
      WITH non_current_listing_changes AS (
        SELECT * FROM listing_changes
        WHERE NOT is_current
      ), exceptions AS (
        SELECT lc.* FROM non_current_listing_changes nc_lc
        JOIN listing_changes lc
        ON lc.parent_id = nc_lc.id
      ), listing_changes_to_delete AS (
        SELECT * FROM non_current_listing_changes
        UNION
        SELECT * FROM exceptions
      ), deleted_listing_distributions AS (
        DELETE FROM listing_distributions
        USING listing_changes_to_delete lc
        WHERE lc.id = listing_distributions.listing_change_id
      ), deleted_annotations AS (
        DELETE FROM annotations
        USING listing_changes_to_delete lc
        WHERE annotations.id = lc.annotation_id
      ), updated_original_id AS (
        UPDATE listing_changes
        SET original_id = NULL
        FROM listing_changes_to_delete
        WHERE listing_changes.original_id = listing_changes_to_delete.id
      )
      DELETE FROM listing_changes
      USING listing_changes_to_delete lc
      WHERE lc.id = listing_changes.id
    SQL
    puts 'Deleting old listing changes'
    ActiveRecord::Base.connection.execute sql
  end

  task :trim_trade_restrictions => :environment do
    sql = <<-SQL
      WITH trade_restrictions_to_delete AS (
        SELECT * FROM trade_restrictions
        WHERE NOT is_current
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
      WHERE tr.id = trade_restrictions.id
    SQL
    puts 'Deleting old trade restrictions'
    ActiveRecord::Base.connection.execute sql
  end

  task :trim_eu_decisions => :environment do
    sql = 'DELETE FROM eu_decisions WHERE NOT is_current'
    puts 'Deleting old EU decisions'
    ActiveRecord::Base.connection.execute sql
  end

  task :trim_users => :environment do
    puts 'Clearing user data'
    ActiveRecord::Base.connection.execute <<-SQL
      UPDATE users SET
        name = 'user ' || users.id,
        email = 'user.' || users.id || '@test.org'
    SQL
  end

  task :drop_temporary_tables => :environment do
    puts 'Dropping temporary tables'
    ActiveRecord::Base.connection.execute 'SELECT * FROM drop_eu_lc_mviews()'
  end

end
