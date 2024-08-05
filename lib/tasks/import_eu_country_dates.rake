namespace :import do
  desc 'Import EU country entry/exit dates from csv file usage: rake import:eu_country_dates'
  task :eu_country_dates => :environment do
    file_path = "#{Rails.root}/lib/files/CITES_trade_EU_countries_list.csv"

    if File.exist?(file_path)
      Rails.logger.info "There are #{EuCountryDate.count} records in the EuCoutryDate table"
      CSV.foreach(file_path, headers: true) do |row|
        geo_entity = GeoEntity.find_by_iso_code2(row['ISO2'])
        accession_year = row['EU_accession_year']
        exit_year = row['EU_exit_year']
        if geo_entity.nil?
          Rails.logger.info "Country #{row['ISO2']} not found in the DB, skipping..."
          next
        else
          EuCountryDate.find_or_create_by!(geo_entity: geo_entity, eu_accession_year: accession_year, eu_exit_year: exit_year)
        end
      end
      Rails.logger.info "There are #{EuCountryDate.count} records in the EuCoutryDate table after the import"
    else
      puts "CITES_trade_EU_countries_list.csv file is missing within the lib/files/ directory"
    end
  end
end
