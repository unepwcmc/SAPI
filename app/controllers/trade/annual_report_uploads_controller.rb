class Trade::AnnualReportUploadsController < ApplicationController
  respond_to :json

  def create
    @annual_report_upload = Trade::AnnualReportUpload.new(params[:source_file])
    respond_with @annual_report_upload
  end

end
