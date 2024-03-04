class Api::V1::PurposesController < ApplicationController
  CACHE_KEY_PREFIX = 'purposes_with_locale_'

  def index
    cache_key = "#{CACHE_KEY_PREFIX}#{I18n.locale}"

    Rails.cache.fetch(cache_key, expires_in: 1.hour) do
      @purposes = Purpose.all.order(:code)

      render :json => @purposes,
        :each_serializer => Species::PurposeSerializer,
        :meta => { :total => @purposes.count }
    end
  end

  def self.invalidate_cache
    I18n.available_locales.each do |lang|
      Rails.cache.delete("#{CACHE_KEY_PREFIX}#{lang}")
    end
  end
end
