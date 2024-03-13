# Constructs a normalised list of parameters, with non-recognised params
# removed.
#
# Array parameters are sorted for caching purposes.
class Trade::SandboxSearchParams < Hash
  include SearchParamSanitiser
  def initialize(params)
    sanitized_params = {
      annual_report_upload_id: sanitise_positive_integer(params[:annual_report_upload_id], nil),
      validation_error_id: sanitise_positive_integer(params[:validation_error_id], nil),
      page: sanitise_positive_integer(params[:page], 1),
      per_page: sanitise_positive_integer(params[:per_page], 100)
    }
    super(sanitized_params)
    self.merge!(sanitized_params)
  end

  def self.sanitize(params)
    new(params)
  end
end
