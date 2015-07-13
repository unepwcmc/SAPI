require Rails.root.join('lib/tasks/elibrary_import/helpers.rb')
namespace 'elibrary:import' do

  def import_table
    :elibrary_events_import
  end

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
        EventName,
        CAST(EventDate AS DATE) AS EventDate,
        splus_event_type
      FROM #{import_table} t
      WHERE EventDate IS NOT NULL AND EventDate != 'NULL'
    SQL
  end

  def rows_to_insert_sql
    sql = <<-SQL
      SELECT * FROM (
        #{all_rows_in_import_table_sql}
      ) new_events
      EXCEPT
      SELECT elib_legacy_id, designation_id, name, effective_at, type FROM (
        #{rows_to_update_sql}
      ) current_events
    SQL
  end

  def rows_to_update_sql
    sql = <<-SQL
      SELECT id, e.designation_id, name, effective_at, type, ne.EventID AS elib_legacy_id
      FROM events e
      JOIN (#{all_rows_in_import_table_sql}) ne
      ON e.designation_id = ne.designation_id
        AND e.name = ne.EventName
        AND e.effective_at = ne.EventDate
        AND e.type = ne.splus_event_type
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

  def print_pre_import_stats
    res = ActiveRecord::Base.connection.execute("SELECT COUNT(*) FROM #{import_table}")
    puts "#{res[0]['count']} rows in #{import_table}"
    sql =<<-SQL
      WITH rows_to_insert AS (
        #{rows_to_insert_sql}
      )
      SELECT COUNT(*) FROM rows_to_insert
    SQL
    res = ActiveRecord::Base.connection.execute(sql)
    puts "#{res[0]['count']} rows to import"
  end

  desc 'Import events from csv file'
  task :events => :environment do |task_name|
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
      UPDATE #{import_table} t
      SET splus_event_type = BTRIM(splus_event_type), EventName = BTRIM(EventName)
    SQL
    ActiveRecord::Base.connection.execute(sql)
    print_events_breakdown
    print_pre_import_stats

    sql = <<-SQL
      WITH rows_to_insert(legacy_id, designation_id, name, effective_at, type) AS (
        #{rows_to_insert_sql}
      )
      INSERT INTO "events" (elib_legacy_id, designation_id, name, effective_at, type, created_at, updated_at)
        SELECT
        rows_to_insert.*,
        NOW(),
        NOW()
      FROM rows_to_insert
    SQL
    ActiveRecord::Base.connection.execute(sql)

    sql = <<-SQL
      WITH rows_to_update_sql AS (
        #{rows_to_update_sql}
      )
      UPDATE events
      SET elib_legacy_id = rows_to_update_sql.elib_legacy_id
      WHERE events.id = rows_to_update_sql.id AND events.elib_legacy_id IS NULL
    SQL

    print_events_breakdown
  end
end
