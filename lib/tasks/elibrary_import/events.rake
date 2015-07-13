require Rails.root.join('lib/tasks/elibrary_import/helpers.rb')
namespace 'elibrary:import' do

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
        EventName,
        CAST(EventDate AS DATE) AS EventDate,
        splus_event_type
      FROM #{import_table}
      WHERE EventDate IS NOT NULL AND EventDate != 'NULL'
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
        AND e.name = ne.EventName
        AND e.type = ne.splus_event_type AND ne.splus_event_type = 'CitesCop'
      WHERE e.published_at IS NULL OR e.elib_legacy_id IS NULL
    SQL
  end

  def rows_to_insert_sql
    sql = <<-SQL
      SELECT * FROM (
        #{all_rows_in_import_table_sql}
      ) all_rows_in_import_table
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

  def print_pre_import_stats
    queries = {'rows_to_import' => "SELECT COUNT(*) FROM #{import_table}"}
    queries['rows_to_insert'] = "SELECT COUNT(*) FROM (#{rows_to_insert_sql}) t"
    queries.each do |q_name, q|
      res = ActiveRecord::Base.connection.execute(q)
      puts "#{res[0]['count']} #{q_name.humanize}"
    end
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
      WITH rows_to_insert(legacy_id, designation_id, name, published_at, type) AS (
        #{rows_to_insert_sql}
      )
      INSERT INTO "events" (elib_legacy_id, designation_id, name, published_at, type, created_at, updated_at)
        SELECT
        rows_to_insert.*,
        NOW(),
        NOW()
      FROM rows_to_insert
    SQL
    ActiveRecord::Base.connection.execute(sql)

    print_events_breakdown
  end
end
