class Trade::SandboxFilter < Trade::Filter

  private

  def initialize_params(options)
    @options = Trade::SandboxSearchParams.sanitize(options)
    @page = @options[:page]
    @per_page = @options[:per_page]
  end

  def initialize_query
    aru = Trade::AnnualReportUpload.find(@options[:annual_report_upload_id])
    ve = Trade::ValidationError.find(@options[:validation_error_id])
    vr = ve.validation_rule
    @query = vr.matching_records_for_aru_and_error(aru, ve)
  end
end
