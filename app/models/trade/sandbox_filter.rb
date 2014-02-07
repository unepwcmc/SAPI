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

    [:appendix, :year, :taxon_name, :taxon_concept_id, :term_code, :unit_code,
     :source_code, :purpose_code, :trading_partner, :country_of_origin,
     :export_permit, :origin_permit, :import_permit, :quantity ].each do |var|
      if @options[var]
        @query = @query.where(var => (@options[var] == "-1" ? nil : @options[var]))
      end
    end
  end
end
