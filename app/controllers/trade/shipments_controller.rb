class Trade::ShipmentsController < TradeController
  respond_to :json

  def index
    @search = Trade::Filter.new(search_params)
    render :json => @search.results,
      :each_serializer => Trade::ShipmentSerializer,
      :meta => metadata_for_search(@search)
  end

  def create
    @shipment = Trade::Shipment.new(shipment_params)
    if @shipment.save
      render :json => @shipment, :status => :ok
    else
      render :json => { "errors" => @shipment.errors }, :status => :unprocessable_entity
    end
  end

  def update
    @shipment = Trade::Shipment.find(params[:id])
    if @shipment.update_attributes(shipment_params)
      render :json => @shipment, :status => :ok
    else
      render :json => { "errors" => @shipment.errors }, :status => :unprocessable_entity
    end
  end

  def destroy
    @shipment = Trade::Shipment.find(params[:id])
    @shipment.destroy
    render :json => nil, :status => :ok
  end

  def destroy_batch
    @search = Trade::Filter.new(params)
    @search.query.destroy_all
    render :json => nil, :status => :ok
  end

private

  def shipment_params
    params.require(:shipment).permit(
      :id,
      :appendix,
      :taxon_concept_id,
      :term_id,
      :quantity,
      :unit_id,
      :importer_id,
      :exporter_id,
      :reporter_type,
      :country_of_origin_id,
      :import_permit_number,
      :export_permit_number,
      :origin_permit_number,
      :purpose_id,
      :source_id,
      :year,
      :ignore_warnings
    )
  end

end
