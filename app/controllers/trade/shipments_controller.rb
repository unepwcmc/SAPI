class Trade::ShipmentsController < ApplicationController
  respond_to :json
  PER_PAGE= 500

  def index
    @shipments = Trade::Shipment.includes([
       :exporter, :importer, :country_of_origin, :purpose,
       :source, :term, :unit, :country_of_origin_permit,
       :import_permit, :export_permits, :taxon_concept
      ]).order('year DESC').offset((params[:page].to_i - 1) * PER_PAGE).limit(PER_PAGE)
    render :json => @shipments,
      :each_serializer => Trade::ShipmentSerializer,
      :meta => {
        :total => Trade::Shipment.count,
        :page => params[:page] || 1,
        :per_page => PER_PAGE
      }
  end

  def create
    @shipment = Trade::Shipment.new(shipment_params)
    if @shipment.save
      render :json => @shipment, :status => :ok
    else
      render :json => @shipment.errors, :status => :unprocessable_entity
    end
  end

  def update
    @shipment = Trade::Shipment.find(params[:id])
    if @shipment.update_attributes(shipment_params)
      render :json => @shipment, :status => :ok
    else
      render :json => @shipment.errors, :status => :unprocessable_entity
    end
  end

  def destroy
    @shipment = Trade::Shipment.find(params[:id])
    @shipment.destroy
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
      :country_of_origin_permit_number,
      :purpose_id,
      :source_id,
      :year,
      :reported_species_name,
      :reported_appendix
    )
  end

end
