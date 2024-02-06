class TradePlusFiltersWorker
  include Sidekiq::Worker
  sidekiq_options :queue => :admin, unique: :until_and_while_executing, retry: false

  def perform(locale)
    I18n.with_locale(locale) do
      cache_key = "#{Api::V1::TradePlusFiltersController::CACHE_KEY_PREFIX}#{I18n.locale}"
      filters_service = Trade::TradePlusFilters.new(locale)
      res = ActiveRecord::Base.connection.execute(filters_service.query)
      filters = filters_service.response_ordering(res)
      Rails.cache.write(cache_key, filters, expires_in: 4.weeks)
    end
  end
end
