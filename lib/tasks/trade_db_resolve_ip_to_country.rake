task :trade_db_resolve_ip_to_country => :environment do
  trade_downloads =
    Trade::TradeDataDownload.where(city: 'Unknown', country: "Unknown", organization: 'Unknown')
                            .where('created_at > ?',"2019-03-11 10:00:55")
  trade_downloads.each do |td|
    puts "Updating Trade download #{td.id}"
    geo_ip_data = Sapi::GeoIP.instance.resolve(td.user_ip)
    td.update_attributes!(geo_ip_data) # TODO: `update_attributes` is deprecated in Rails 6, and removed from Rails 7.
  end
end
