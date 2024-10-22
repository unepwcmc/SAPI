class Api::V1::TradePlusFiltersController < ApplicationController
  respond_to :json

  CACHE_KEY_PREFIX = 'trade_plus_filters_with_locale_'

  def index
    cache_key = "#{CACHE_KEY_PREFIX}#{I18n.locale}"

    filters =
      Rails.cache.fetch(cache_key, expires_in: 4.weeks) do
        filters_service = Trade::TradePlusFilters.new(locale)
        res = ActiveRecord::Base.connection.execute(filters_service.query)

        filters_service.response_ordering(res)
      end

    render json: filters
  end
end
