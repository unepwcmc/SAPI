class QuotaObserver < ActiveRecord::Observer

  def after_destroy(quota)
    DownloadsCacheCleanupWorker.perform_async(:quotas)
  end

end