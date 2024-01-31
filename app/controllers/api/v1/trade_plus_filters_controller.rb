class Api::V1::TradePlusFiltersController < ApplicationController
  respond_to :json

  def index
    locale = params['locale'] || I18n.default_locale.to_s
    filters_service = Trade::TradePlusFilters.new(locale)
    filters = Rails.cache.fetch(['trade_plus_filters', locale], expires_in: 4.weeks) do
      res = ApplicationRecord.connection.execute(filters_service.query)
      filters_service.response_ordering(res)
    end

    render :json => filters
  end
end
