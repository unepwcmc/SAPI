require Rails.root.join('lib/tasks/elibrary/helpers.rb')
namespace 'elibrary:events' do

  def import_table; :elibrary_events_import; end

  def all_rows_in_import_table_sql
    cites = fetch_designation_or_fail('CITES')
    eu = fetch_designation_or_fail('EU')
    sql = <<-SQL
      SELECT
        EventID,
        CASE
          WHEN splus_event_type = 'EcSrg' THEN #{eu.id}
          ELSE #{cites.id}
        END AS designation_id,
        BTRIM(EventName) AS EventName,
        CASE WHEN EventDate = 'NULL' THEN NULL ELSE CAST(EventDate AS DATE) END AS EventDate,
        BTRIM(splus_event_type) AS splus_event_type
      FROM #{import_table}
    SQL
  end

  # CITES CoPs are special, because they pre-existed in the system
  # need to update them with the elib_legacy_id & published_at date
  # matching depends on the event name & type
  def cops_to_update_sql
    sql = <<-SQL
      SELECT id, e.designation_id, name, type, ne.EventID AS elib_legacy_id, ne.EventDate AS published_at
      FROM (#{all_rows_in_import_table_sql}) ne
      JOIN events e
      ON e.designation_id = ne.designation_id
        AND UPPER(e.name) = UPPER(ne.EventName)
        AND UPPER(e.type) = UPPER(ne.splus_event_type) AND ne.splus_event_type = 'CitesCop'
      WHERE e.published_at IS NULL OR e.elib_legacy_id IS NULL
    SQL
  end

  def rows_to_insert_sql
    sql = <<-SQL
      SELECT * FROM (
        #{all_rows_in_import_table_sql}
      ) all_rows_in_import_table
      WHERE EventDate IS NOT NULL
      EXCEPT
      SELECT elib_legacy_id, e.designation_id, name, published_at, type FROM (
        #{all_rows_in_import_table_sql}
      ) ne
      JOIN events e
      ON e.elib_legacy_id = ne.EventID
    SQL
  end

  def fetch_designation_or_fail(name)
    d = Designation.find_by_name(name)
    unless d
      fail "Designation #{name} missing from target DB"
    end
    d
  end

  def print_events_breakdown
    puts "#{Time.now} There are #{Event.count} events in total"
    Event.group(:type).order(:type).count.each do |type, count|
      puts "\t #{type} #{count}"
    end
  end

  desc 'Import events from csv file'
  task :import => :environment do |task_name|
    check_file_provided(task_name)
    drop_table_if_exists(import_table)
    columns_with_type = [
      ['EventTypeID', 'INT'],
      ['EventTypeName', 'TEXT'],
      ['splus_event_type', 'TEXT'],
      ['EventID', 'INT'],
      ['EventName', 'TEXT'],
      ['MeetingType', 'TEXT'],
      ['EventDate', 'TEXT']
    ]
    create_table_from_column_array(
      import_table, columns_with_type.map{ |ct| ct.join(' ') }
    )
    copy_from_csv(
      ENV['FILE'], import_table, columns_with_type.map{ |ct| ct.first }
    )

    sql = <<-SQL
      WITH cops_to_update AS (
        #{cops_to_update_sql}
      )
      UPDATE events
      SET elib_legacy_id = cops_to_update.elib_legacy_id,
        published_at = cops_to_update.published_at
      FROM cops_to_update
      WHERE events.id = cops_to_update.id
    SQL
    ActiveRecord::Base.connection.execute(sql)

    print_events_breakdown
    print_pre_import_stats

    sql = <<-SQL
      WITH rows_to_insert AS (
        #{rows_to_insert_sql}
      )
      INSERT INTO "events" (elib_legacy_id, designation_id, name, published_at, type, created_at, updated_at)
        SELECT
        EventID,
        designation_id,
        EventName,
        EventDate,
        splus_event_type,
        NOW(),
        NOW()
      FROM rows_to_insert
    SQL
    ActiveRecord::Base.connection.execute(sql)

    print_events_breakdown
  end

end
