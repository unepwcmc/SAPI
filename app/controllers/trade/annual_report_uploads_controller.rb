class Trade::AnnualReportUploadsController < ApplicationController
  respond_to :json

  def index
    respond_with Trade::AnnualReportUpload.all
  end

  def show
    respond_with Trade::AnnualReportUpload.find(params[:id])
  end

  def create
    @annual_report_upload = Trade::AnnualReportUpload.create()
    @annual_report_upload.save_temp_file(params[:source_file])
    respond_with @annual_report_upload
  end

end
