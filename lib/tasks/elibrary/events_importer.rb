require Rails.root.join('lib/tasks/elibrary/importable.rb')

class Elibrary::EventsImporter
  include Elibrary::Importable

  def initialize(file_name)
    @file_name = file_name
  end

  def table_name
    :elibrary_events_import
  end

  def columns_with_type
    [
      ['EventTypeID', 'INT'],
      ['EventTypeName', 'TEXT'],
      ['splus_event_type', 'TEXT'],
      ['EventID', 'INT'],
      ['EventName', 'TEXT'],
      ['MeetingType', 'TEXT'],
      ['EventDate', 'TEXT']
    ]
  end

  def run_preparatory_queries
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

    sql = <<-SQL
      WITH srgs_to_update AS (
        #{srgs_to_update_sql}
      )
      UPDATE events
      SET elib_legacy_id = srgs_to_update.elib_legacy_id,
        published_at = srgs_to_update.published_at
      FROM srgs_to_update
      WHERE events.id = srgs_to_update.id
    SQL
    ActiveRecord::Base.connection.execute(sql)
  end

  def run_queries
    sql = <<-SQL
      WITH rows_to_insert AS (
        #{rows_to_insert_sql}
      )
      INSERT INTO "events" (elib_legacy_id, designation_id, name, effective_at, published_at, type, created_at, updated_at)
        SELECT
        EventID,
        designation_id,
        EventName,
        EventDate,
        EventDate,
        splus_event_type,
        NOW(),
        NOW()
      FROM rows_to_insert
    SQL
    ActiveRecord::Base.connection.execute(sql)
  end

  def all_rows_sql
    cites = Designation.find_by_name('CITES')
    sql = <<-SQL
      SELECT
        EventID,
        CASE
          WHEN splus_event_type = 'EcSrg' THEN NULL
          ELSE #{cites.id}
        END AS designation_id,
        BTRIM(EventName) AS EventName,
        CASE WHEN EventDate = 'NULL' THEN NULL ELSE CAST(EventDate AS DATE) END AS EventDate,
        BTRIM(splus_event_type) AS splus_event_type
      FROM #{table_name}
    SQL
  end

  # CITES CoPs are special, because they pre-existed in the system
  # need to update them with the elib_legacy_id & published_at date
  # matching depends on the event name & type
  def cops_to_update_sql
    sql = <<-SQL
      SELECT id, e.designation_id, name, type, ne.EventID AS elib_legacy_id, ne.EventDate AS published_at
      FROM (#{all_rows_sql}) ne
      JOIN events e
      ON e.designation_id = ne.designation_id
        AND UPPER(e.name) = UPPER(ne.EventName)
        AND UPPER(e.type) = UPPER(ne.splus_event_type) AND ne.splus_event_type = 'CitesCop'
      WHERE e.published_at IS NULL OR e.elib_legacy_id IS NULL
    SQL
  end

  # EC SRGs are special, because they pre-existed in the system
  # need to update them with the elib_legacy_id & published_at date
  # matching depends on the event name & type
  def srgs_to_update_sql
    sql = <<-SQL
      SELECT id, e.designation_id, name, type, ne.EventID AS elib_legacy_id, ne.EventDate AS published_at
      FROM (#{all_rows_sql}) ne
      JOIN events e -- designation_id left empty for EC SRGs
      ON UPPER(e.name) = UPPER(ne.EventName)
        AND UPPER(e.type) = UPPER(ne.splus_event_type) AND ne.splus_event_type = 'EcSrg'
      WHERE e.published_at IS NULL OR e.elib_legacy_id IS NULL
    SQL
  end

  def rows_to_insert_sql
    sql = <<-SQL
      SELECT * FROM (
        #{all_rows_sql}
      ) all_rows_in_table_name
      WHERE splus_event_type IS NOT NULL AND EventDate IS NOT NULL
      EXCEPT
      SELECT elib_legacy_id, e.designation_id, name, published_at, type FROM (
        #{all_rows_sql}
      ) ne
      JOIN events e
      ON e.elib_legacy_id = ne.EventID
    SQL
  end

  def print_breakdown
    puts "#{Time.now} There are #{Event.count} events in total"
    Event.group(:type).order(:type).count.each do |type, count|
      puts "\t #{type} #{count}"
    end
  end

end
