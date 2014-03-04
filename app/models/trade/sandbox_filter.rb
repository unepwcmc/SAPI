class Trade::SandboxFilter < Trade::Filter

  private

  def initialize_params(options)
    @options = Trade::SandboxSearchParams.sanitize(options)
    @page = @options[:page]
    @per_page = @options[:per_page]
  end

  def initialize_query
    aru = Trade::AnnualReportUpload.find(@options[:annual_report_upload_id])
    sandbox_klass = Trade::SandboxTemplate.ar_klass(aru.sandbox.table_name)
    @query = sandbox_klass.scoped

    @query = @query.where(:id => @options[:sandbox_shipments_ids])
  end
end
