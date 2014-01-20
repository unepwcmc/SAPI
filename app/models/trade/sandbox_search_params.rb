# Constructs a normalised list of parameters, with non-recognised params
# removed.
#
# Array parameters are sorted for caching purposes.
class Trade::SandboxSearchParams < Hash
  def initialize(params)
    sanitized_params = {
      :annual_report_upload_id => params[:annual_report_upload_id],
      :appendix => params[:appendix],
      :species_name => params[:species_name],
      :term_code => params[:term_code],
      :unit_code => params[:unit_code],
      :source_code => params[:source_code],
      :purpose_code => params[:purpose_code],
      :trading_partner => params[:trading_partner],
      :country_of_origin => params[:country_of_origin],
      :export_permit => params[:export_permit],
      :origin_permit => params[:origin_permit],
      :import_permit => params[:import_permit],
      :year => params[:year],
      :page => params[:page] && params[:page].to_i > 0 ? params[:page].to_i : 1,
      :per_page => params[:per_page] && params[:per_page].to_i > 0 ? params[:per_page].to_i : 100
    }
    super(sanitized_params)
    self.merge!(sanitized_params)
  end

  def self.sanitize(params)
    new(params)
  end
end
