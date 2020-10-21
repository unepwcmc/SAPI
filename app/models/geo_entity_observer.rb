class GeoEntityObserver < ActiveRecord::Observer

  def after_save(geo_entity)
    GeoEntitySearch.increment_cache_iterator
    Rails.cache.delete_matched('*ShowTaxonConceptSerializerCites*')
  end

  def after_destroy(geo_entity)
    GeoEntitySearch.increment_cache_iterator
  end
end
