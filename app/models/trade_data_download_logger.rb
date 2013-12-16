module TradeDataDownloadLogger

  module_function

  def log_download request, params
    unless params['origin'] == 'public' then return end
    data = {}
    filters = params['filters']
    data["user_ip"] = request.ip
    data["report_type"] = filters['report_type']
    data["year_from"] = filters['time_range_start']
    data["year_to"] = filters['time_range_end']
    data["appendix"] = filters['appendix']
    data["unit"] = filters['unit']
    data["taxon"] = filters['selection_taxon']
    data["term"] = self.get_field_values(filters['terms_ids'], Term)
    data["purpose"] = self.get_field_values(filters['purposes_ids'], Purpose)
    data["source"] = self.get_field_values(filters['sources_ids'], Source)
    data["importer"] = self.get_field_values(filters['importers_ids'], GeoEntity)
    data["exporter"] = self.get_field_values(filters['exporters_ids'], GeoEntity)

    w = TradeDataDownload.new(data)
    w.save
  end

  private

  def self.get_field_values param, model
    if param == "" then return 'All' end
    if param == nil then return '' end
    if model.to_s == 'GeoEntity'
      return model.find_all_by_id(param.map(&:to_i)).
        map { |r| r.iso_code2 }.join ','
    else
      return model.find_all_by_id(param.map(&:to_i)).
        map { |r| r.code }.join ','
    end
  end
end