class DocumentObserver < ActiveRecord::Observer

  def after_save(taxon_concept)
    DocumentSearch.increment_cache_iterator
  end

  def after_destroy(taxon_concept)
    DocumentSearch.increment_cache_iterator
  end

end
