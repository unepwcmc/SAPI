class EuSuspensionRegulationObserver < ActiveRecord::Observer

  def after_create(eu_suspension_regulation)
    unless eu_suspension_regulation.eu_suspensions_event_id.blank?
      EventEuSuspensionCopyWorker.perform_async(
        eu_suspension_regulation.eu_suspensions_event_id,
        eu_suspension_regulation.id
      )
      DownloadsCacheCleanupWorker.perform_async(:eu_decisions)
    end
  end

  def after_update(eu_suspension_regulation)
    eu_suspension_regulation.touch_suspensions_and_taxa
    DownloadsCacheCleanupWorker.perform_async(:eu_decisions)
  end
end
