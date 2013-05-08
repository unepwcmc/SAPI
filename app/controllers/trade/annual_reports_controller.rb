class Trade::AnnualReportsController < ApplicationController
  respond_to :json

  def index
    respond_with Trade::AnnualReport.all
  end

  def show
    respond_with Trade::AnnualReport.find(params[:id])
  end
end
