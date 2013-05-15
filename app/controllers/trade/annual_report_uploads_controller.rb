class Trade::AnnualReportUploadsController < ApplicationController
  respond_to :json

  def index
    respond_with []
  end

  def show
    respond_with Trade::AnnualReportUpload.find(params[:id])
  end

  def create
    @annual_report_upload = Trade::AnnualReportUpload.create(
      params.slice(:csv_source_file)
    )
    render :json => {:files => [@annual_report_upload.to_jq_upload]}
  end

end
