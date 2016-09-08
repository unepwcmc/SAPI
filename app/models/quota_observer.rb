class QuotaObserver < TradeRestrictionObserver

  def after_destroy(quota)
    DownloadsCacheCleanupWorker.perform_async(:quotas)
  end

end
