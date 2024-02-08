class Api::V1::TradePlusFiltersController < ApplicationController
  respond_to :json

  CACHE_KEY_PREFIX = 'trade_plus_filters_with_locale_'

  def index
    cache_key = "#{CACHE_KEY_PREFIX}#{I18n.locale}"
    filters = Rails.cache.read(cache_key)
    if filters.nil?
      TradePlusFiltersWorker.perform_async(I18n.locale)
      head 500 # Cache not ready yet.
    else
      render :json => filters
    end
  end
end
