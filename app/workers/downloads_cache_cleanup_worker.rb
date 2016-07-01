class DownloadsCacheCleanupWorker
  include Sidekiq::Worker
  sidekiq_options :queue => :admin, :backtrace => 50

  def perform(type_of_cache)
    DownloadsCache.send(:"clear_#{type_of_cache}")
  end
end
