class DocumentObserver < ActiveRecord::Observer

  def after_save(document)
    sync_sort_index(document)
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

  def sync_sort_index(document)
    if document.sort_index_changed?
      if document.primary_language_document &&
        document.primary_language_document_id != document.id
        document.primary_language_document.update_attribute(
          :sort_index,
          document.sort_index
        )
      else
        document.secondary_language_documents(true).each do |d|
          d.update_attribute(
            :sort_index,
            document.sort_index
          )
        end
      end
    end
  end

end
