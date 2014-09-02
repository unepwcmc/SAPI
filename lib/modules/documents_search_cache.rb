# See the SearchCache module for explanations

require 'digest/md5'
module DocumentsSearchCache

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
    raw_key = @options.merge(:locale => I18n.locale).to_a.sort.
      unshift("#{self.class.name}-results").
      push(self.class.cache_iterator).inspect
    Rails.logger.debug raw_key
    Digest::MD5.hexdigest(raw_key)
  end

  def total_cnt_cache_key
    raw_key = @options.merge(:locale => I18n.locale).to_a.sort.
      unshift("#{self.class.name}-total_cnt").
      push(self.class.cache_iterator).inspect
    Rails.logger.debug raw_key
    Digest::MD5.hexdigest(raw_key)
  end

end
