class Trade::AnnualReportUploadsController < ApplicationController
  respond_to :json

  def create
      @annual_report_upload = Trade::AnnualReportUpload.new(params[:annual_report_upload])
      respond_with @annual_report_upload
  end

end
