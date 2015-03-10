class CitesSuspensionObserver < TradeRestrictionObserver

  def after_destroy(cites_suspension)
    DownloadsCacheCleanupWorker.perform_async(:cites_suspensions)
  end

end
