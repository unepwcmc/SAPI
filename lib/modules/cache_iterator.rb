module CacheIterator

  def cache_iterator
    cache_key = "#{self.class.name}-#{id}-cache-iterator"
    # fetch the cache key
    # if there isn't one yet, assign it a random integer between 0 and 10
    val = Rails.cache.fetch(cache_key) { rand(10) }
    # Invalidate cache if value is a string. This seems to happen when switching ruby version
    if val.is_a?(String)
      new_val = rand(10)
      Rails.cache.write(cache_key, new_val) && new_val
    else
      val
    end
  end

  def increment_cache_iterator
    Rails.logger.debug "#{self.class.name} #{id} incrementing cache iterator"
    Rails.cache.write("#{self.class.name}-#{id}-cache-iterator", self.cache_iterator + 1)
    self.class.increment_cache_iterator
  end

  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods

    def cache_iterator
      cache_key = "#{name}-cache-iterator"
      # fetch the cache key
      # if there isn't one yet, assign it a random integer between 0 and 10
      val = Rails.cache.fetch(cache_key) { rand(10) }
      # Invalidate cache if value is a string. This seems to happen when switching ruby version
      if val.is_a?(String)
        new_val = rand(10)
        Rails.cache.write(cache_key, new_val) && new_val
      else
        val
      end
    end

    def increment_cache_iterator
      Rails.logger.debug "#{name} incrementing cache iterator"
      Rails.cache.write("#{name}-cache-iterator", self.cache_iterator + 1)
    end
  end

end
