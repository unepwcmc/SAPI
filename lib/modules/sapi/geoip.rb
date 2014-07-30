# Returns UTF8
class Sapi::GeoIP
  include Singleton

  def initialize
    @city_db = ::GeoIP.new(GEO_IP_CONFIG['city_db'])
    @org_db = GEO_IP_CONFIG['org_db'] && ::GeoIP.new(GEO_IP_CONFIG['org_db'])
  end

  def resolve(ip)
    result = country_and_city(ip).merge(organisation(ip))
    result.each do |k, v|
      result[k] = if v.nil?
        'Unknown'
      else
        v.force_encoding("ISO-8859-1").encode("UTF-8")
      end
    end
  end

  def country_and_city(ip)
    cdb_names = @city_db.city(ip)
    country = cdb_names.try(:country_code2)
    city = cdb_names.try(:city_name)
    {
      country: country,
      city: city
    }
  end

  def organisation(ip)
    org_names = @org_db && @org_db.organization(ip)
    org = org_names.try(:isp)
    { organization: org }
  end

end
