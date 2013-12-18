module Trade::TradeDataDownloadLogger

  module_function

  def log_download request, params, rows

    if params['internal'] == true then return end
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
    data["taxon"] = params['filters']['selection_taxon']
    data["term"] = self.get_field_values(filters[:terms_ids], Term)
    data["purpose"] = self.get_field_values(filters[:purposes_ids], Purpose)
    data["source"] = self.get_field_values(filters[:sources_ids], Source)
    data["importer"] = self.get_field_values(filters[:importers_ids], GeoEntity)
    data["exporter"] = self.get_field_values(filters[:exporters_ids], GeoEntity)

    w = Trade::TradeDataDownload.new(data)
    w.save
  end

  module_function

  def export
    file_name = self.get_file_name
    unless File.file?(PATH + file_name)
      File.open(PATH + self.get_file_name, 'w') do |f|
        Trade::TradeDataDownload.pg_copy_to do |line|
          f.write line
        end
      end
    end
    PATH + file_name
  end

  PATH = "public/downloads/trade_download_stats/"

  private

  def self.get_file_name
    'trade_download_stats.csv'
  end

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
end