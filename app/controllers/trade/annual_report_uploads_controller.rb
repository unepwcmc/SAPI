class Trade::AnnualReportUploadsController < ApplicationController
  respond_to :json

  def index
    respond_with []
  end

  def show
    respond_with Trade::AnnualReportUpload.find(params[:id])
  end

  def create
    @annual_report_upload = Trade::AnnualReportUpload.new(
      params.slice(:csv_source_file)
    )
    if @annual_report_upload.save
      render :json => @annual_report_upload
    else
      render :json => {
        :errors => @annual_report_upload.errors.full_messages
      }, :status => 422
    end
  end

end
