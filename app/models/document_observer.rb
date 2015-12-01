class DocumentObserver < ActiveRecord::Observer

  def after_save(document)
    DocumentSearch.increment_cache_iterator
    RefreshDocumentsWorker.perform_async
  end

  def after_destroy(document)
    DocumentSearch.increment_cache_iterator
    RefreshDocumentsWorker.perform_async
  end

end
