class Trade::AnnualReportUploadObserver < ActiveRecord::Observer

  def after_create(annual_report_upload)
    annual_report_upload.copy_to_sandbox
  end

  def before_destroy(annual_report_upload)
    annual_report_upload.sandbox && annual_report_upload.sandbox.destroy
  end
end
