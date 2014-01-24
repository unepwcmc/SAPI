class Trade::SandboxShipmentsController < ApplicationController
  respond_to :json

  def index
    @search = Trade::SandboxFilter.new(params)
    render :json => @search.results,
      :each_serializer => Trade::SandboxShipmentSerializer,
      :meta => {
      :total => @search.total_cnt,
      :page => @search.page,
      :per_page => @search.per_page
    }
  end

  def update
    aru = Trade::AnnualReportUpload.find(params[:annual_report_upload_id])
    sandbox_klass = Trade::SandboxTemplate.ar_klass(aru.sandbox.table_name)
    @sandbox_shipment = sandbox_klass.find(params[:id])
    @sandbox_shipment.delete_or_update_attributes(params[:sandbox_shipment])
    head :no_content
  end
end
