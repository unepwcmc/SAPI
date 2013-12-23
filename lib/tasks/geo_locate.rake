namespace :geo_locate do
  task visits: :environment do
    require 'geoip'
    require 'geocoder'

    cdb = GeoIP::City.new(GEO_IP_CONFIG['city_db'])
    orgdb = GeoIP::Organization.new(GEO_IP_CONFIG['org_db'])

    Visit.un_geolocated.each do |visit|
      visit.geo_locate cdb,orgdb
      visit.save
    end
  end
end
