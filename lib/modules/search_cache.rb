# This module can be used to cache queries encapsulated in their own search
# classes. It is used to cache TaxonConcept searches in Species+ and Checklist,
# as well as documents search in the new E-Library and geo entities search.
#
# This module makes the following assumptions about cached classes:
# - has an @options hash property with all parameters to construct a unique cache key
# - responds to results (which returns expected results for given parameters)
# - responds to total_cnt (which returns total number of results for given parameters)

require 'digest/md5'
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

  def generic_cache_key(suffix)
    raw_key = @options.merge(:locale => I18n.locale).to_a.sort.
      unshift("#{self.class.name}-#{suffix}").
      push(self.class.cache_iterator).inspect
    Rails.logger.debug raw_key
    Digest::MD5.hexdigest(raw_key)
  end

  def results_cache_key
    generic_cache_key('results')
  end

  def total_cnt_cache_key
    generic_cache_key('total_cnt')
  end

end
