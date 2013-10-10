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
end

