require 'sapi/geoip'
module Trade::TradeDataDownloadLogger

  module_function

  def log_download(request, search_params, rows)
    data = {}
    data["user_ip"] = request.ip
    data["number_of_rows"] = rows
    data["report_type"] = search_params['report_type']
    data["year_from"] = search_params[:time_range_start]
    data["year_to"] = search_params[:time_range_end]
    data["appendix"] = search_params['appendix']
    data["unit"] = search_params['unit']
    data["taxon"] = TaxonConcept.where(:id => search_params[:taxon_concepts_ids]).
      order(:full_name).select(:full_name).map(&:full_name).join(", ")
    data["term"] = self.get_field_values(search_params[:terms_ids], Term)
    data["purpose"] = self.get_field_values(search_params[:purposes_ids], Purpose)
    data["source"] = self.get_field_values(search_params[:sources_ids], Source)
    data["importer"] = self.get_field_values(search_params[:importers_ids], GeoEntity)
    data["exporter"] = self.get_field_values(search_params[:exporters_ids], GeoEntity)
    geo_ip_data = Sapi::GeoIP.instance.resolve(request.ip)
    [:country, :city, :organization].each do |col|
      data[col] = geo_ip_data[col]
    end
    w = Trade::TradeDataDownload.new(data)
    w.save
  end

  private

  def self.get_field_values(param, model)
    if param == "" then return 'All' end
    if param == nil then return '' end
    if model.to_s == 'GeoEntity'
      return model.where(id: param.map(&:to_i)).to_a.
        map { |r| r.iso_code2 }.join ' '
    else
      return model.where(id: param.map(&:to_i)).to_a.
        map { |r| r.code }.join ' '
    end
  end

end
