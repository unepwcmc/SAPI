class Trade::AnnualReportUploadObserver <  ActiveRecord::Observer

  def after_create(annual_report_upload)
    annual_report_upload.copy_to_sandbox
  end

end
