class Api::V1::SourcesController < ApplicationController
  CACHE_KEY_PREFIX = 'sources_with_locale_'

  def index
    cache_key = "#{CACHE_KEY_PREFIX}#{I18n.locale}"

    Rails.cache.fetch(cache_key, expires_in: 1.hour) do
      @sources = Source.all.order(:code)

      render :json => @sources,
        :each_serializer => Species::SourceSerializer,
        :meta => { :total => @sources.count }
    end
  end

  def self.invalidate_cache
    I18n.available_locales.each do |lang|
      Rails.cache.delete("#{CACHE_KEY_PREFIX}#{lang}")
    end
  end
end
