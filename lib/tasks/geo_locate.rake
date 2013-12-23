namespace :geo_locate do
  task data_downloads: :environment do

    ips_to_geo_locate = Trade::TradeDataDownload.where(country: nil)
    
    cdb = GeoIP.new(GEO_IP_CONFIG['city_db'])
    orgdb = GeoIP.new(GEO_IP_CONFIG['org_db'])

    ips_to_geo_locate.each do |download|
      ip = download.user_ip
      cdb_names = cdb.city(ip)
      org_names = orgdb.organization(ip)
      country = cdb_names.nil? ? "Unkwown" : cdb_names.country_code2
      city = cdb_names.nil? ? "Unkwown" : cdb_names.city_name
      organization = org_names.nil? ? "Unkown" : org_names.isp

      Trade::TradeDataDownload.find(download.id).update_attributes(city: city, country: country, organization: organization)
    end
      



  end
end
