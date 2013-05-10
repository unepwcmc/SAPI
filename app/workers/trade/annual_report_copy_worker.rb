class Trade::AnnualReportCopyWorker
  include Sidekiq::Worker
  sidekiq_options :queue => :trade, :backtrace => true
  def perform(annual_report_upload)
    annual_report_upload.copy_to_sandbox
  end
end
