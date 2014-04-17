module Trade::TradeDataDownloadLogger

  module_function

  def log_download request, params, rows
    data = {}
    # !! Not all the params can be sanitized with Trade::SearchParams.sanitize
    filters = Trade::SearchParams.sanitize(params['filters'])
    data["user_ip"] = request.ip
    data["number_of_rows"] = rows
    data["report_type"] = params['filters']['report_type']
    data["year_from"] = filters[:time_range_start]
    data["year_to"] = filters[:time_range_end]
    data["appendix"] = params['filters']['appendix']
    data["unit"] = params['filters']['unit']
    data["taxon"] = TaxonConcept.where(:id => filters[:taxon_concepts_ids]).
      order(:full_name).select(:full_name).map(&:full_name).join(", ")
    data["term"] = self.get_field_values(filters[:terms_ids], Term)
    data["purpose"] = self.get_field_values(filters[:purposes_ids], Purpose)
    data["source"] = self.get_field_values(filters[:sources_ids], Source)
    data["importer"] = self.get_field_values(filters[:importers_ids], GeoEntity)
    data["exporter"] = self.get_field_values(filters[:exporters_ids], GeoEntity)
    data["city"], data["country"] = self.city_country_from(request.ip).map do |s|
      s.force_encoding("ISO-8859-1").encode("UTF-8")
    end
    data["organization"] = self.organization_from(request.ip).
      force_encoding("ISO-8859-1").encode("UTF-8")
    w = Trade::TradeDataDownload.new(data)
    w.save
  end

  private

  def self.get_field_values param, model
    if param == "" then return 'All' end
    if param == nil then return '' end
    if model.to_s == 'GeoEntity'
      return model.find_all_by_id(param.map(&:to_i)).
        map { |r| r.iso_code2 }.join ' '
    else
      return model.find_all_by_id(param.map(&:to_i)).
        map { |r| r.code }.join ' '
    end
  end

  def self.city_country_from ip
    cdb = GeoIP.new(GEO_IP_CONFIG['city_db'])
    cdb_names = cdb.city(ip)
    country = cdb_names.nil? ? "Unknown" : cdb_names.country_code2
    city = cdb_names.nil? ? "Unknown" : cdb_names.city_name
    [city, country]
  end

  def self.organization_from ip
    orgdb = GeoIP.new(GEO_IP_CONFIG['org_db'])
    org_names = orgdb.organization(ip)
    org_names.nil? ? "Unknown" : org_names.isp
  end
end
