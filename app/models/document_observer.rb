class DocumentObserver < ActiveRecord::Observer

  def after_save(document)
    sync_sort_index(document)
    DocumentSearch.clear_cache
  end

  def after_destroy(document)
    DocumentSearch.clear_cache
  end

  private

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
