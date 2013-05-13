class Trade::AnnualReportUploadsController < ApplicationController
  respond_to :json

  def create
    @annual_report_upload = Trade::AnnualReportUpload.create()
    @annual_report_upload.save_temp_file(params[:source_file])
    respond_with @annual_report_upload
  end

end
