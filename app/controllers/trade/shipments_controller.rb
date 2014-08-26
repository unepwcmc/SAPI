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

  def update_batch
    @search = Trade::Filter.new(search_params)
    cnt = @search.query.count
    @search.query.update_all(batch_update_params)
    render :json => {rows: cnt}, :status => :ok
  end

  def destroy
    @shipment = Trade::Shipment.find(params[:id])
    @shipment.destroy
    render :json => nil, :status => :ok
  end

  def destroy_batch
    @search = Trade::Filter.new(search_params)
    cnt = @search.query.count
    @search.query.destroy_all
    render :json => {rows: cnt}, :status => :ok
  end

private

  def shipment_attributes
    [
      :id,
      :appendix,
      :taxon_concept_id,
      :reported_taxon_concept_id,
      :term_id,
      :quantity,
      :unit_id,
      :importer_id,
      :exporter_id,
      :reporter_type,
      :country_of_origin_id,
      :purpose_id,
      :source_id,
      :year
    ]
  end

  def shipment_params
    params.require(:shipment).permit(
      *(shipment_attributes + [
        :import_permit_number,
        :export_permit_number,
        :origin_permit_number,
        :ignore_warnings
      ])
    )
  end

  def batch_update_params
    res = params.permit(
      :updates => shipment_attributes
    ).delete(:updates)
    reporter_type = res.delete(:reporter_type)
    unless reporter_type.blank?
      res[:reported_by_exporter] = Trade::Shipment.reporter_type_to_reported_by_exporter(reporter_type)
    end
    res
  end

end
