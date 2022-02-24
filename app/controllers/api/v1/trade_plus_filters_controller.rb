class Api::V1::TradePlusFiltersController < ApplicationController
  respond_to :json

  def index
    filters_service = Trade::TradePlusFilters.new(params['locale'])
    filters = Rails.cache.fetch(['trade_plus_filters', params['locale']], expires_in: 4.weeks) do
      res = ActiveRecord::Base.connection.execute(filters_service.query)
      filters_service.response_ordering(res)
    end

    render :json => filters
  end
end
