require 'zip'
require 'fileutils'
namespace :export do
  task :trade_db => :environment do
    RECORDS_PER_FILE = 500000
    ntuples = RECORDS_PER_FILE
    offset = 0
    i = 0
    dir = 'tmp/trade_db_files/'
    FileUtils.mkdir_p dir
    begin
      while(ntuples == RECORDS_PER_FILE) do
        i = i + 1
        query = Trade::ShipmentReportQueries.full_db_query(RECORDS_PER_FILE, offset)
        results = ActiveRecord::Base.connection.execute query
        ntuples = results.ntuples
        columns = results.fields
        columns.map do |column|
          column.capitalize!
          column.gsub! '_', ' '
        end
        values = results.values
        Rails.logger.info("Query executed returning #{ntuples} records!")
        filename = "trade_db_#{i}.csv"
        Rails.logger.info("Processing batch number #{i} in #{filename}.")
        File.open("#{dir}#{filename}", 'w') do |file|
          file.write columns.join(',')
          values.each do |record|
            file.write "\n"
            file.write record.join(',')
          end
        end
        offset = offset + RECORDS_PER_FILE
      end
      Rails.logger.info("Trade database completely exported!")
      zipfile = 'tmp/trade_db_files/trade_db.zip'
      Zip::File.open(zipfile, Zip::File::CREATE) do |zipfile|
        (1..i).each do |index|
          filename = "trade_db_#{index}.csv"
          zipfile.add(filename, dir + filename)
        end
      end
    rescue => e
      Rails.logger.info("Export aborted!")
      Rails.logger.info("Caught exception #{e}")
      Rails.logger.info(e.message)
    end
  end
end
