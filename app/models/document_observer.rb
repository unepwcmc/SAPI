class DocumentObserver < ActiveRecord::Observer

  def after_save(document)
    clear_cache
  end

  def after_destroy(document)
    clear_cache
  end

  private

  def clear_cache
    DocumentSearch.increment_cache_iterator
    RefreshDocumentsWorker.perform_async
    DownloadsCacheCleanupWorker.perform_async(:documents)
  end

end
