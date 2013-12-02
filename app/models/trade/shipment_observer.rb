class Trade::ShipmentObserver < ActiveRecord::Observer

  def before_save(shipment)
    unless shipment.reported_taxon_concept_id
      shipment.reported_taxon_concept_id  = shipment.taxon_concept_id
    end
  end

  def after_save(shipment)
    DownloadsCache.clear_shipments
  end

  def after_destroy(shipment)
    DownloadsCache.clear_shipments
  end

end