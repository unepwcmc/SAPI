class Trade::ShipmentObserver < ActiveRecord::Observer

  def after_save(shipment)
    DownloadsCache.clear_shipments
  end

  def after_destroy(shipment)
    DownloadsCache.clear_shipments
  end

end