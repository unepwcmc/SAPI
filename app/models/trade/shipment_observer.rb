class Trade::ShipmentObserver < ActiveRecord::Observer
  include PgArrayParser

  def before_save(shipment)
    @old_permits_ids = []
    [
      shipment.import_permits_ids_was,
      shipment.export_permits_ids_was,
      shipment.origin_permits_ids_was
    ].each do |permits_ids|
      # no idea why this is sometimes a string and sometimes an Array
      @old_permits_ids +=
        if permits_ids.is_a?(Array)
          permits_ids.dup
        else
          parse_pg_array(permits_ids || '')
        end
    end
    unless shipment.reported_taxon_concept_id
      shipment.reported_taxon_concept_id  = shipment.taxon_concept_id
    end
  end

  def before_destroy(shipment)
    @old_permits_ids = shipment.permits_ids.dup
  end

  def after_save(shipment)
    DownloadsCacheCleanupWorker.perform_async(:shipments)
    disconnected_permits_ids = @old_permits_ids - shipment.permits_ids
    PermitCleanupWorker.perform_async(disconnected_permits_ids)
  end

  def after_destroy(shipment)
    DownloadsCacheCleanupWorker.perform_async(:shipments)
    disconnected_permits_ids = @old_permits_ids
    PermitCleanupWorker.perform_async(disconnected_permits_ids)
  end

end