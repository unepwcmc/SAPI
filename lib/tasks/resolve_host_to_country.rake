task :resolve_host_to_country => :environment do
  require 'csv'
  hosts = CSV.read('/home/agnessa/Data/hosts.csv', headers: true)
  hosts_and_countries = hosts.map do |row|
    geo_ip_data = Sapi::GeoIP.instance.resolve(row[0])
    [row[0], geo_ip_data[:country]]
  end
  CSV.open('/home/agnessa/Data/hosts_and_countries.csv', 'w') do |csv|
    csv << ['Host', 'Country']
    hosts_and_countries.each { |row| csv << row }
  end
end
