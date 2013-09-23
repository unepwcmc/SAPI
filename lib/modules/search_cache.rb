# This module can be used to cache queries encapsulated in their own search
# classes. It s used to cache TaxonConcept searches in Species+ and Checklist.
# 
# This module makes the following assumptions about cached classes:
# - responds to cache_key and returns and object that can be used as Rails.cache key
# e.g. normalised search parameters
# - responds to results (which returs expected results for given parameters)
# - responds to total_cnt (which returns total number of results for given parameters)

module SearchCache

  def cached_results
    Rails.cache.fetch(results_cache_key, :expires_in => 24.hours) do
      results
    end
  end

  def cached_total_cnt
    Rails.cache.fetch(total_cnt_cache_key, :expires_in => 24.hours) do
      total_cnt
    end
  end

private

  def results_cache_key
    Rails.logger.debug @options.to_a.sort.unshift("#{self.class.name}-results").
      push(self.class.cache_iterator).inspect
    @options.to_a.sort.unshift("#{self.class.name}-results").
      push(self.class.cache_iterator)
  end

  def total_cnt_cache_key
    Rails.logger.debug @options.to_a.sort.unshift("#{self.class.name}-total_cnt").
      push(self.class.cache_iterator).inspect
    @options.to_a.sort.unshift("#{self.class.name}-total_cnt").
      push(self.class.cache_iterator)
  end

end
