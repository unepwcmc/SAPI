class Trade::SandboxShipmentsController < TradeController
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
    @sandbox_shipment.update_attributes(sandbox_shipment_params)
    head :no_content
  end

  def destroy
    aru = Trade::AnnualReportUpload.find(params[:annual_report_upload_id])
    sandbox_klass = Trade::SandboxTemplate.ar_klass(aru.sandbox.table_name)
    @sandbox_shipment = sandbox_klass.find(params[:id])
    @sandbox_shipment.destroy
    aru.update_attribute(:number_of_rows, aru.sandbox_shipments.size)
    head :no_content
  end

  def update_batch
    aru = Trade::AnnualReportUpload.find(params[:annual_report_upload_id])
    ve = Trade::ValidationError.find(params[:validation_error_id])
    sandbox_klass = Trade::SandboxTemplate.ar_klass(aru.sandbox.table_name)
    sandbox_klass.update_batch(
      update_batch_params[:updates], ve, aru
    )
    head :no_content
  end

  def destroy_batch
    aru = Trade::AnnualReportUpload.find(params[:annual_report_upload_id])
    ve = Trade::ValidationError.find(params[:validation_error_id])
    sandbox_klass = Trade::SandboxTemplate.ar_klass(aru.sandbox.table_name)
    sandbox_klass.destroy_batch(ve, aru)
    aru.update_attribute(:number_of_rows, aru.sandbox_shipments.size)
    head :no_content
  end

  private

  def sandbox_shipment_params
    params.require(:sandbox_shipment).permit(*sandbox_shipment_attributes)
  end

  def destroy_batch_params
    params.permit(:annual_report_upload_id, :validation_error_id)
  end

  def update_batch_params
    params.permit(
      :annual_report_upload_id,
      :validation_error_id,
      :updates => sandbox_shipment_attributes
    )
  end

  def sandbox_shipment_attributes
    [
      :appendix,
      :taxon_concept_id,
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
    ]
  end

end
