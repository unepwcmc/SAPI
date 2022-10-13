namespace :import do
  desc 'Import EU country entry/exit dates from csv file usage: rake import:eu_country_statuses'
  task :eu_country_dates => :environment do
    file_path = "#{Rails.root}/lib/files/CITES_trade_EU_countries_list.csv"

    if File.exists?(file_path)
      CSV.foreach(file_path, headers: true) do |row|
      
	    geo_entity = GeoEntity.find_by_iso_code2(row['ISO2'])              
	    accession_year = row['EU_accession_year']
	    exit_year = row['EU_exit_year']
	    unless geo_entity.nil?
	      geo_entity.eu_country_dates.find_or_create_by(eu_accession_year: accession_year, eu_exit_year: exit_year)
	    end
	  end
      puts "EU country records imported"
    else
      puts "CITES_trade_EU_countries_list.csv file is missing within the lib/files/ directory"
    end
  end
end
