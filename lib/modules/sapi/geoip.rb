# Returns UTF8
class Sapi::GeoIP
  include Singleton

  def initialize
    begin
      @city_db = GEO_IP_CONFIG['city_db'] && ::GeoIP.new(GEO_IP_CONFIG['city_db'])
    rescue Errno::ENOENT
      @city_db = nil
    end
    begin
      @org_db = GEO_IP_CONFIG['org_db'] && ::GeoIP.new(GEO_IP_CONFIG['org_db'])
    rescue Errno::ENOENT
      @org_db = nil
    end
  end

  def resolve(ip)
    result = country_and_city(ip).merge(organisation(ip))
    result.each do |k, v|
      result[k] =
        if v.nil?
          'Unknown'
        else
          v.force_encoding("ISO-8859-1").encode("UTF-8")
        end
    end
  end

  def country_and_city(ip)
    cdb_names = @city_db && @city_db.city(ip)
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

  def default_separator(ip)
    invalid_addresses = ['127.0.0.1', nil, 'localhost', 'nil', '', 'unknown']

    if invalid_addresses.include?(ip)
      :comma
    else
      ip_data = country_and_city(ip)
      country = ip_data[:country]
      separator_char = (country ? DEFAULT_COUNTRY_SEPARATORS[country.to_sym] : ',')
      (separator_char == ';' ? :semicolon : :comma)
    end
  end

end
