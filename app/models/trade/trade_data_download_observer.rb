class Trade::TradeDataDownloadObserver < ActiveRecord::Observer

  def after_save(download_log)
    DownloadsCache.clear_trade_download_stats
  end

end