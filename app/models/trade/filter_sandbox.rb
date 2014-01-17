class Trade::FilterSandbox < Trade::Filter

  private

  def initialize_params(options)
    @options = Trade::SandboxSearchParams.sanitize(options)
    @options.keys.each { |k| instance_variable_set("@#{k}", @options[k]) }
  end

  def initialize_query
    aru = Trade::AnnualReportUpload.find(@annual_report_upload_id)
    sandbox_klass = Trade::SandboxTemplate.ar_klass(aru.sandbox.table_name)
    @query = sandbox_klass.scoped

    @query = @query.where(:appendix => @appendix) if @appendix
  end
end
