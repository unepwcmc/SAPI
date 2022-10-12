namespace :import do

	desc 'Import EU country entry/exit dates from csv file usage: rake import:eu_country_statuses'
	task :eu_country_statuses => :environment do

		file_path = "#{Rails.root}/lib/files/CITES_trade_EU_countries_list.csv"

		if File.exists?(file_path)
			csv = CSV.read(file_path, headers: true)
			count = 0
			csv.each do |row|
	          geo_entity = GeoEntity.find_by_iso_code2(row[0])	          
	          accession_year = row[5]
	          exit_year = row[7]
	          unless geo_entity.nil?
	          	value = EuCountryStatus.where(geo_entity_id: geo_entity.id, eu_accession_year: accession_year, eu_exit_year: exit_year).count	          	
	          	if value == 0
	          	  puts "Creating data for #{geo_entity.name_en}"
	              geo_entity.eu_country_statuses.create(eu_accession_year: accession_year, eu_exit_year: exit_year)
	              count+=1
	            end
	          end
	        end
	        puts "#{count} country records imported"
		else
			puts "CITES_trade_EU_countries_list.csv file is missing within the lib/files/ directory"
		end
	end
end