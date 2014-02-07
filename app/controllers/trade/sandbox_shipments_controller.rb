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
    @sandbox_shipment.delete_or_update_attributes(sandbox_shipment_params)
    head :no_content
  end

private

  def sandbox_shipment_params
    params.require(:sandbox_shipment).permit(
      :appendix,
      :taxon_name,
      :term_code,
      :quantity,
      :unit_code,
      :trading_partner,
      :country_of_origin,
      :import_permit,
      :export_permit,
      :origin_permit,
      :purpose_code,
      :source_code,
      :year
    )
  end

end
