class Trade::ShipmentsController < ApplicationController
  respond_to :json

  def index
    respond_with Trade::Shipment.includes([
       :exporter, :importer, :country_of_origin, :purpose,
       :source, :term, :unit, :country_of_origin_permit,
       :import_permit, :export_permit, :taxon_concept
      ]).page(1).limit(250)
  end
end

