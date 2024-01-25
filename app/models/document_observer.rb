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
    # Rails 5.1 to 5.2
    # DEPRECATION WARNING: The behavior of `attribute_was` inside of after callbacks will be changing in the next version of Rails.
    # The new return value will reflect the behavior of calling the method after `save` returned (e.g. the opposite of what it returns now).
    # To maintain the current behavior, use `attribute_before_last_save` instead.
    #
    # DEPRECATION WARNING: The behavior of `attribute_changed?` inside of after callbacks will be changing in the next version of Rails.
    # The new return value will reflect the behavior of calling the method after `save` returned (e.g. the opposite of what it returns now).
    # To maintain the current behavior, use `saved_change_to_attribute?` instead.
    #
    # DEPRECATION WARNING: The behavior of `changed_attributes` inside of after callbacks will be changing in the next version of Rails.
    # The new return value will reflect the behavior of calling the method after `save` returned (e.g. the opposite of what it returns now).
    # To maintain the current behavior, use `saved_changes.transform_values(&:first)` instead.
    #
    # == Original code ==
    # if document.sort_index_changed?
    # == Changed to fix deprecation warnings ==
    if document.saved_change_to_sort_index?
      if document.primary_language_document &&
        document.primary_language_document_id != document.id
        document.primary_language_document.update_attribute(
          :sort_index,
          document.sort_index
        )
      else
        document.secondary_language_documents.reload.each do |d|
          d.update_attribute(
            :sort_index,
            document.sort_index
          )
        end
      end
    end
  end

end
