class Trade::TradeDataDownloadObserver < ActiveRecord::Observer

  def after_save(download_log)
    DownloadsCacheCleanupWorker.perform_async(:trade_download_stats)
  end

end
