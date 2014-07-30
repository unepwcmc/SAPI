# Returns UTF8
class Sapi::GeoIP
  include Singleton

  def initialize
    @city_db = GeoIP.new(GEO_IP_CONFIG['city_db'])
    @org_db = GEO_IP_CONFIG['org_db'] && ::GeoIP.new(GEO_IP_CONFIG['org_db'])
  end

  def resolve(ip)
    # city and country
    cdb_names = @city_db.city(ip)
    country, city = if cdb_names.nil?
      ['Unknown', 'Unknown', 'Unknown']
    else
      [
        cdb_names.country_code2.force_encoding("ISO-8859-1").encode("UTF-8"),
        cdb_names.city_name.force_encoding("ISO-8859-1").encode("UTF-8")
      ]
    end

    # organisation (if available)
    org_names = @org_db && @org_db.organization(ip)
    org = if org_names.nil?
      'Unknown'
    else
      org_names.isp.force_encoding("ISO-8859-1").encode("UTF-8")
    end

    {
      country: country,
      city: city,
      organization: org
    }
  end
end
