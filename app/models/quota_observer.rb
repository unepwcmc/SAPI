class QuotaObserver < ActiveRecord::Observer

  def after_destroy(quota)
    DownloadsCache.clear_quotas
  end

end