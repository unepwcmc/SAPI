class DownloadsCacheUpdateJob < ApplicationJob
  queue_as :admin

  def perform(*args)
    DownloadsCache.update
  end
end
