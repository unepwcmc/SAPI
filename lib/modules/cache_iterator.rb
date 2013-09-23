module CacheIterator

  def cache_iterator
    # fetch the cache key
    # if there isn't one yet, assign it a random integer between 0 and 10
    Rails.cache.fetch("#{self.class.name}-#{id}-cache-iterator") { rand(10) }
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
      # fetch the cache key
      # if there isn't one yet, assign it a random integer between 0 and 10
      Rails.cache.fetch("#{name}-cache-iterator") { rand(10) }
    end

    def increment_cache_iterator
      Rails.logger.debug "#{name} incrementing cache iterator"
      Rails.cache.write("#{name}-cache-iterator", self.cache_iterator + 1)
    end

  end

end