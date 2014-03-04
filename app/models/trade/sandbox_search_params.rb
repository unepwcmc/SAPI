# Constructs a normalised list of parameters, with non-recognised params
# removed.
#
# Array parameters are sorted for caching purposes.
class Trade::SandboxSearchParams < Hash
  def initialize(params)
    sanitized_params = {
      :annual_report_upload_id => params[:annual_report_upload_id],
      :sandbox_shipments_ids => params[:sandbox_shipments_ids] && params[:sandbox_shipments_ids].split(","),
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
