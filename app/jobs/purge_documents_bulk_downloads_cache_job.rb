class PurgeDocumentsBulkDownloadsCacheJob < ApplicationJob
  queue_as :admin

  RETENTION_DAYS = 7

  def perform(retention_days = RETENTION_DAYS)
    # These `DocumentsBulkDownload` rows are a reusable cache, not permanent
    # records. Evicting them after the retention window keeps storage bounded
    # while still leaving enough time for the same document selection to be
    # reused without regenerating immediately.
    #
    # Completed downloads behave like an LRU cache, so we evict based on the
    # last successful download time. Rows that were never completed/downloaded
    # fall back to `created_at` so abandoned pending or failed requests still
    # age out.
    DocumentsBulkDownload.where(
      'COALESCE(last_download_at, created_at) < ?',
      retention_days.days.ago
    ).find_each do |documents_bulk_download|
      # Destroying the row also destroys the Active Storage attachment, which
      # schedules blob purging via the attachment's default `dependent:
      # :purge_later` behavior. That keeps this cache eviction path simple,
      # while the existing unattached-blob cleanup job remains a fallback if
      # asynchronous blob deletion is delayed.
      documents_bulk_download.destroy!
    end
  end
end
