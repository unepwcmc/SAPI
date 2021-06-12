require 'zip'
require 'fileutils'
namespace :export do
  task :trade_db => :environment do
    RECORDS_PER_FILE = 500000
    ntuples = RECORDS_PER_FILE
    offset = 0
    dir = 'tmp/trade_db_files/'
    FileUtils.mkdir_p dir
    export(ntuples, offset, dir)
  end

  task :trade_db_from_created_at, [:created_at] => :environment do |_, args|
    RECORDS_PER_FILE = 500000
    ntuples = RECORDS_PER_FILE
    offset = 0
    dir = 'tmp/trade_db_files/'
    FileUtils.mkdir_p dir
    opts = { created_at: args[:created_at] }
    export(ntuples, offset, dir, opts)
  end

  # The main request here was to export records which have been updated after a given date
  # so excluding the ones created before that date
  task :trade_db_from_updated_at, [:updated_at, :created_at] => :environment do |_, args|
    RECORDS_PER_FILE = 500000
    ntuples = RECORDS_PER_FILE
    offset = 0
    dir = 'tmp/trade_db_files/'
    FileUtils.mkdir_p dir
    opts = { updated_at: args[:updated_at], created_at: args[:created_at] }
    export(ntuples, offset, dir, opts)
  end

  task :trade_db_by_year => :environment do
    RECORDS_PER_FILE = 500000
    dir = 'tmp/trade_db_files/'
    FileUtils.mkdir_p dir
    export_by_year(dir)
  end

  task :trade_db_single_file => :environment do
    RECORDS_PER_FILE = 500000
    ntuples = RECORDS_PER_FILE
    offset = 0
    dir = 'tmp/trade_db_files/'
    FileUtils.mkdir_p dir
    export_in_single_file(ntuples, offset, dir)
  end

  def export_in_single_file(ntuples, offset, dir)
    i = 0
    filename = 'trade_db_full_export.csv'
    path_to_file = dir + filename
    begin
      while(ntuples == RECORDS_PER_FILE) do
        i = i + 1
        query = Trade::ShipmentReportQueries.full_db_query_single_file(RECORDS_PER_FILE, offset)
        results = ActiveRecord::Base.connection.execute query
        ntuples = results.ntuples
        values = results.values

        Rails.logger.info("Query executed returning #{ntuples} records!")

        File.open(path_to_file, 'a') do |file|
          if i == 1
            columns = results.fields
            columns.map do |column|
              column.capitalize!
              column.gsub! '_', ' '
            end
            file.write(columns.join(','))
          end

          values.each do |record|
            file.write("\n")
            file.write(record.join(','))
          end
        end

        offset = offset + RECORDS_PER_FILE
      end
      Rails.logger.info("Trade database completely exported!")
      zipfile = 'tmp/trade_db_files/trade_db.zip'
      Zip::File.open(zipfile, Zip::File::CREATE) do |zipfile|
          zipfile.add(filename, path_to_file)
      end
      delete_csv_files(dir)
    rescue => e
      Rails.logger.info("Export aborted!")
      Rails.logger.info("Caught exception #{e}")
      Rails.logger.info(e.message)
    end
  end

  def export_by_year(dir)
    range = (1975..2016)
    begin
      range.each do |year|
        if (2012..2015).include?(year)
          kingdom = 'Animalia'
          query = Trade::ShipmentReportQueries.full_db_query_by_kingdom(year, kingdom)
          results = ActiveRecord::Base.connection.execute query
          ntuples = results.ntuples
          options = {
            dir: dir,
            ntuples: ntuples,
            index: nil,
            year: year,
            kingdom: kingdom
          }
          process_results(results, options)

          kingdom = 'Plantae'
          query = Trade::ShipmentReportQueries.full_db_query_by_kingdom(year, kingdom)
          results = ActiveRecord::Base.connection.execute query
          ntuples = results.ntuples
          options = {
            dir: dir,
            ntuples: ntuples,
            index: nil,
            year: year,
            kingdom: kingdom
          }
          process_results(results, options)
        else
          query = Trade::ShipmentReportQueries.full_db_query_by_year(year)
          results = ActiveRecord::Base.connection.execute query
          ntuples = results.ntuples
          options = {
            dir: dir,
            ntuples: ntuples,
            index: nil,
            year: year,
            kingdom: nil
          }
          process_results(results, options)
        end
      end
      Rails.logger.info("Trade database completely exported!")
      zipfile = 'tmp/trade_db_files/trade_db.zip'
      Zip::File.open(zipfile, Zip::File::CREATE) do |zipfile|
        range.each do |year|
          if (2012..2015).include?(year)
            filename = "trade_db_#{year}_Animalia.csv"
            zipfile.add(filename, dir + filename)
            filename = "trade_db_#{year}_Plantae.csv"
            zipfile.add(filename, dir + filename)
          else
            filename = "trade_db_#{year}.csv"
            zipfile.add(filename, dir + filename)
          end
        end
      end
      delete_csv_files(dir)
    rescue => e
      Rails.logger.info("Export aborted!")
      Rails.logger.info("Caught exception #{e}")
      Rails.logger.info(e.message)
    end
  end

  def export(ntuples, offset, dir, opts=nil)
    i = 0
    begin
      while(ntuples == RECORDS_PER_FILE) do
        i = i + 1
        # If options are passed, it means a partial query has been requested.
        query = Trade::ShipmentReportQueries.partial_db_query(RECORDS_PER_FILE, offset, opts) if opts
        # Default to a full export query otherwise
        query = query ? query : Trade::ShipmentReportQueries.full_db_query(RECORDS_PER_FILE, offset)

        results = ActiveRecord::Base.connection.execute query
        ntuples = results.ntuples
        options = {
          dir: dir,
          ntuples: ntuples,
          index: i,
          year: nil,
          kingdom: nil
        }
        process_results(results, options)
        offset = offset + RECORDS_PER_FILE
        query = nil
      end
      Rails.logger.info("Trade database completely exported!")
      zipfile = 'tmp/trade_db_files/trade_db.zip'
      Zip::File.open(zipfile, Zip::File::CREATE) do |zipfile|
        (1..i).each do |index|
          filename = "trade_db_#{index}.csv"
          path_to_file = dir + filename
          zipfile.add(filename, path_to_file)
        end
      end
      delete_csv_files(dir)
    rescue => e
      Rails.logger.info("Export aborted!")
      Rails.logger.info("Caught exception #{e}")
      Rails.logger.info(e.message)
    end
  end

  def delete_csv_files(dir)
    Dir.glob("#{dir}/trade_db*.csv").each { |file| File.delete(file) }
  end

  def process_results(results, options)
    columns = results.fields
    columns.map do |column|
      column.capitalize!
      column.gsub! '_', ' '
    end
    values = results.values
    Rails.logger.info("Query executed returning #{options[:ntuples]} records!")
    filename = ''
    if options[:index]
      filename = "trade_db_#{options[:index]}.csv"
    elsif options[:year]
      filename = "trade_db_#{options[:year]}.csv"
      filename = "trade_db_#{options[:year]}_#{options[:kingdom]}.csv" if options[:kingdom]
    else
      filename = "trade_db_full_export.csv"
    end
    Rails.logger.info("Processing #{filename}.")
    File.open("#{options[:dir]}#{filename}", 'w') do |file|
      file.write columns.join('|')
      values.each do |record|
        file.write "\n"
        file.write record.join('|')
      end
    end
  end
end
