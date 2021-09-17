class TradePlusFiltersWorker
  include Sidekiq::Worker

  def perform
    filters_service = Trade::TradePlusFilters
    Rails.cache.fetch('trade_plus_filters', expires_in: 1.week) do
      res = ActiveRecord::Base.connection.execute(filters_service.query)
      filters_service.response_ordering(res)
    end
  end
end