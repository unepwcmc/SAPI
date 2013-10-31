class Trade::ShipmentsController < ApplicationController
  respond_to :json
  PER_PAGE= 500

  def index
    @shipments = Trade::Shipment.includes([
       :exporter, :importer, :country_of_origin, :purpose,
       :source, :term, :unit, :country_of_origin_permit,
       :import_permit, :export_permit, :taxon_concept
      ]).order('year DESC').page(params[:page]).limit(PER_PAGE)
    render :json => @shipments,
      :each_serializer => Trade::ShipmentSerializer,
      :meta => {
        :total => Trade::Shipment.count,
        :page => params[:page] || 1,
        :per_page => PER_PAGE
      }
  end

  def update
    @shipment = Trade::Shipment.find(params[:id])
    if @shipment.update_attributes(shipment_params)
      render :json => @shipment, :status => :ok
    else
      render :json => @shipment.errors, :status => :unprocessable_entity
    end
  end

private

  def shipment_params
    params.require(:shipment).permit(
      :id,
      :appendix,
      :species_name,
      :term_code,
      :quantity,
      :unit_code,
      :importer_id,
      :exporter_id,
      :reporter_type,
      :country_of_origin_id,
      :import_permit,
      :export_permit,
      :origin_permit,
      :purpose_code,
      :source_code,
      :year,
      :reported_species_name,
      :reported_appendix,
      :_destroyed
    )
  end

end
